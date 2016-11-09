function Run_diff_motion_naturalscenes
% One grating at the center, Natural images (or the other grating) at the background
%
% Modified from DriftDemo5(angle, cyclespersecond, f, drawmask)
% Modified from OMS_SimpleMove
% Modified from OMS_diff_motion_phase_scan 10/03/2016 Juyoung

commandwindow % Change focus to command window

%%
StimSize_Ct = 800; % um
StimSize_BG = 2.0; % mm
BarWidth = 67; % um; Grating Bar; 2*Bar = 1 period; ~RF size of BP
w_Annulus = BarWidth;
%
    waitframes = 1;   % 1 means 60 Hz refresh rate ~ 16.6 ms
%%
Duration_inSecs = 60;
%me = ex.params;
me.global = 1;     % jitter        
me.naturalscenesBG = 0;
me.off_bg = 0;
me.jumpevery = 30; % frames
me.drifting = 1;
me.driftingBg = 0;
me.jitterBg = [1 0];        % [x y] weight factor of jitter (or FEM)   
me.jitterCt = [1 0];        % [x y] weight factor of jitter (or FEM)   
me.jitterRatio = 1;    % weight factor of center jitter even in the global motion
D_Speed = linspace(100, 400, 8);
me.imgdir = 'images_sub/'; 
me.imgext = '*.mat';
me.ndims = [200 200];
me.contrast = 1;
me.seed = 150;
addpath(me.imgdir)
%%
% Angles of gratings
angleCenter = 0; 
%angleBG = 0;
angleBG = [0];
%angleBG = linspace(45,360,8);

%%
w_Annulus = Pixel_for_Micron(w_Annulus);
rBG = Pixel_for_Micron(StimSize_BG*1000/2.); % Half-Size of the Backgr grating 
rCt = Pixel_for_Micron(StimSize_Ct/2.); % Half-Size of the Center grating
barWidthPixels = Pixel_for_Micron(BarWidth);
%
p = 2*barWidthPixels; % pixels /one cycle (= wavelength) ~2*Bipolar cell RF
f = 1./p;    % Grating cycles/pixel; spatial phase velocity
fr=f*2*pi;   % phase per one pixel
speed = Pixel_for_Micron(D_Speed);
%%
try
    AssertOpenGL; 
    % Get the list of screens and choose the one with the highest screen number.
    screenNumber=max(Screen('Screens'));
    % Find the color values which correspond to white and black.
    white=WhiteIndex(screenNumber);
    black=BlackIndex(screenNumber);
    
    % Round gray to integral number, to avoid roundoff artifacts with some
    % graphics cards:
    gray=round((white+black)/2);
    % This makes sure that on floating point framebuffers we still get a
    % well defined gray. It isn't strictly neccessary in this demo:
    if gray == white
      gray=white / 2;
    end
    inc=white-gray;

    %% Open a window with a gray background:
    s.rate = Screen('NominalFrameRate', screenNumber);
    if any([s.rate == 0, screenNumber == 0])
        Screen('Preference', 'SkipSyncTests',1);
        [s.window, s.screenRect]=Screen('OpenWindow',screenNumber, gray, [10 10 1010 1160]);
        oldtxtsize = Screen('TextSize', s.window, 17);
    else
        Screen('Resolution', screenNumber, 800, 600, 60);
        [s.window, s.screenRect]=Screen('OpenWindow',screenNumber, gray);
        oldtxtsize = Screen('TextSize', s.window, 9);
        HideCursor(screenNumber);
    end
    pd = DefinePD(s.window);
    
    %% load natural images 
    % initialize random seed
    if isfield(me, 'seed')
      rs = getrng(me.seed);
    else
      rs = getrng();
    end
    files = dir(fullfile(me.imgdir, me.imgext));
    numimages = length(files);
    images = cell(numimages, 1);
    for fileidx = 1:numimages
        images(fileidx) = struct2cell(load(fullfile(me.imgdir, files(fileidx).name)));
    end
        
    %% Drifting grating (@ Center)
    % Calculate parameters of the grating:
    BG_visiblesize = 2*rBG + 1;
    Ct_visiblesize = 2*rCt + 1; % center texture size?

    %% Grating texture ids
    % BG
    [x ,~]=meshgrid(-rBG:rBG + p, 1);
    grating_BG = gray + inc*cos(fr *x );   % inc = white-gray ~ contrast : Grating
    Bg_gratingtex = Screen('MakeTexture', s.window, grating_BG);
    % Center
    [x2,~]=meshgrid(-rCt:rCt + p, 1);
    grating_Ct = gray + inc*cos(fr *x2);
    Ct_gratingtex = Screen('MakeTexture', s.window, grating_Ct);
    % Null gray
    gray_tex = Screen('MakeTexture', s.window, gray); % No pattern at Bg

    %% Mask texture id for Bg
    mask = ones(2*rBG+1, 2*rBG+1, 2) * gray; % Why 2 layers? LA (Luminance + Alpha)
    [x, y] = meshgrid(-1*rBG:1*rBG,-1*rBG:1*rBG);
    % Gaussian profile can be introduced at the 1st Luminance layer.
    mask(:, :, 2) = white * (1-(x.^2 + y.^2 <= rBG^2));
    masktex = Screen('MakeTexture', s.window, mask);

    %% Natural image setting
    % image patch matrix given contrast (L + 2*p)
    L = me.ndims;
    %L = [BG_visiblesize BG_visiblesize]+ 2*p
    
    %% jitter initial offset
    offset_Ct = [0 0];
    offset_Bg = [0 0];
    %% Drift speed of center object (grating)
    % Query duration of monitor refresh interval:
    ifi = Screen('GetFlipInterval', s.window)
    % speed of grating shift
    shiftperframe = speed * waitframes * ifi; % pixels per one stim frame
    
    %%
    N_StimFrames = round(Duration_inSecs/(ifi*waitframes));  
    WaitStartKey(s.window);
    device_id = MyKbQueueInit; % paired with "KbQueueFlush()"
    vbl=0;
    
    %%  
        for cur_frame = 1:N_StimFrames
            %% Jitter amplitude at each frame
            % two ways of jittering
            % 1. Get new patch at the jittered position
            % 2. New src rectangle in same image and texture id.
            jitter_Bg = (randi(rs, 3, 1, 2) - 2) .* me.jitterBg;
            jitter_Ct = (randi(rs, 3, 1, 2) - 2) .* me.jitterCt;
            if me.global 
                jitter_Ct = jitter_Bg;
            end
            jitter_Ct = jitter_Ct * me.jitterRatio;

            %% Total offset with saccadic eye movement at the Bg occasionally
            if mod(cur_frame, me.jumpevery) == 1
                % Saccade in BG: Pick a new image
                % Image normalization
                img = rescale(images{randi(rs, numimages)}); % rescale the range of values in image (function defined in the below by Lane)
                % Size check: 
                if min(size(img)) - 2*L <= 0
                    disp('Original image size is smaller than 2 times of the patch size in pixesl. Enlargement may be needed.');
                    L = round(0.3*size(img));
                end
                % [row col] position in the new image. 
                row = randi(rs, size(img,1) - 2*L(1)) + round(0.5*L(1));
                col = randi(rs, size(img,2) - 2*L(2)) + round(0.5*L(2));

                % Saccade of Bg & Ct gratings (180 phase shift)
                offset_Bg = offset_Bg + p/2.;
                offset_Ct = offset_Ct + p/2.;

                % Different moving object in Ct (change drifting speed)


            else % Fixational eye movements
                % Natural images: add jitter to previous position. 
                row = mod(row + jitter_Bg(2), round(size(img,1)-L(1)));
                col = mod(col + jitter_Bg(1), round(size(img,2)-L(2)));
                % FEM of Gratings 
                offset_Bg = offset_Bg + jitter_Bg;
                offset_Bg = mod(offset_Bg, p);
                offset_Ct = offset_Ct + jitter_Ct;
                offset_Ct = mod(offset_Ct, p);
            end
            %% Texture id for natural image
            patch = 2 * img(row:(row + L(1) - 1), col:(col + L(2) - 1)) * me.contrast + (1 - me.contrast);
            tex_Natural = Screen('MakeTexture', s.window, gray * patch);

            %% drifting of center object [x y]
            if me.drifting
                offset_Ct = mod(offset_Ct - round([shiftperframe(1), 0]), p);
            end
            %% drifting of Bg grating [x y]
            if me.driftingBg
                offset_Bg = mod(offset_Bg - round([shiftperframe(1), 0]), p);
            end

            %% Choose and Draw textures at Center and BG.
            if me.naturalscenesBG
                tex_Bg = tex_Natural;
                tex_Ct = Ct_gratingtex;
                offset_Bg = []; % texture will be resized to fit to destination rect size. 
            else
                tex_Bg = Bg_gratingtex;
                tex_Ct = Ct_gratingtex;
            end

            if me.off_bg
                tex_Bg = gray_tex;
            end

            draw_Bg_Ct_texture(s, tex_Bg, tex_Ct, masktex, BG_visiblesize, Ct_visiblesize, offset_Bg, offset_Ct);


            %% photodiode
            %Screen('FillOval', s.window, xoffset_Ct/0.5*(white-gray)+gray, pd);
            if cur_frame ==1
                Screen('FillOval', s.window, white, pd);
            end

            %% Flip 'waitframes' monitor refresh intervals after last redraw.
            vbl = Screen('Flip', s.window, vbl + (waitframes - 0.5) * ifi);
            cur_frame = cur_frame + 1;

            %% Keyboard check
            if KbCheck(-1)
                break;
            end
        end % for loop
    
    %%
    KbQueueFlush(device_id(1));
    KbQueueStop(device_id(1));
    
    % gray screen at last
    Screen('FillRect', s.window, gray/4);
    Screen('Flip', s.window, 0);
    % pause until Keyboard pressed
    KbWait(-1, 2); 
    
    %
    Screen('CloseAll'); % same as "sca"
    Priority(0);
    ShowCursor();
catch
    %this "catch" section executes in case of an error in the "try" section
    %above. Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
    KbQueueFlush(device_id(1));
    KbQueueStop(device_id(1));
    ShowCursor();
end %try..catch..


end