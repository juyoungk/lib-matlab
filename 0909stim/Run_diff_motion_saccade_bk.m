function Run_diff_motion_saccade
% One grating at the center, Natural images (or the other grating) at the background
%
% Modified from DriftDemo5(angle, cyclespersecond, f, drawmask)
% Modified from OMS_SimpleMove
% Modified from OMS_diff_motion_phase_scan 10/03/2016 Juyoung

commandwindow % Change focus to command window

%%
StimSize_Ct = 800; % um
StimSize_BG = 2.5; % mm
BarWidth = 67; % um; Grating Bar; 2*Bar = 1 period; ~RF size of BP
w_Annulus = BarWidth;
%
waitframes = 1;    % 1 means 60 Hz refresh rate ~ 16.6 ms
%%
%Duration_inSecs = 60;
%me = ex.params;
me.n_saccade = 20; % # of saccades
% every scene will evoke different amount of peripheral effect. However,
% this inhomogeneuty of saccadic excitation would help to test the robustness
% of neural coding for moving object. Encoding of speed should be robust
% regardless of what the Bg image is. 
i_control_1 = 15;
i_control_2 = 30;
me.jumpevery = 45; % frames % A half is for saccadic effect, the other half is for control.
%
me.global = 1;     % jitter is global?
me.naturalscenes = 1;
me.off_bg = 0;
me.drifting = 1;   % constant speed of drifting for object in Ct
me.driftingBg = 0;
me.ndims = [100 100];
me.jitter = 1;
me.jitterBg = 1;   % Jitter amplitude
me.jitterCt = 1;   % Jitter amplitude
me.jitterRatio = 1;    % Weight factor of center jitter even in the global motion
d_speed = linspace(0, 400, 8); % drift speed. um/second. 0 = global motion
me.imgdir = 'images_sub/'; 
me.imgext = '*.mat';

me.contrast = 1;
me.seed = 150;
addpath(me.imgdir)

%%
w_Annulus = Pixel_for_Micron(w_Annulus);
rBg = Pixel_for_Micron(StimSize_BG*1000/2.); % radius of the Bg image
rCt = Pixel_for_Micron(StimSize_Ct/2.);      % radius of the Ct image
barWidthPixels = Pixel_for_Micron(BarWidth);

%% Natural image setting
L_Bg = me.ndims;
L_Ct = round(StimSize_Ct/(StimSize_BG*1000)*L_Bg); % pixel number for the image @ Center
% Scale bar for the image: 1 pixel of the stimulus = ? pixels in the image


%%
p = 2*barWidthPixels; % pixels /one cycle (= wavelength) ~2*Bipolar cell RF
f = 1./p;    % Grating cycles/pixel; spatial phase velocity
fr= f*2*pi;   % phase per one pixel
speed = Pixel_for_Micron(d_speed);
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
    Bg_visiblesize = 2*rBg + 1;
    Ct_visiblesize = 2*rCt + 1; % center texture size?

    %% Grating texture ids
    % BG
    [x ,~]=meshgrid(-rBg:rBg + p, 1);
    grating_BG = gray + inc*cos(fr *x );   % inc = white-gray ~ contrast : Grating
    Bg_gratingtex = Screen('MakeTexture', s.window, grating_BG);
    % Center
    [x2,~]=meshgrid(-rCt:rCt + p, 1);
    grating_Ct = gray + inc*cos(fr *x2);
    Ct_gratingtex = Screen('MakeTexture', s.window, grating_Ct);
    % Null (gray uniform)
    gray_tex = Screen('MakeTexture', s.window, gray); % Single value. No pattern at Bg

    %% Mask texture id for Bg
    mask = ones(2*rBg+1, 2*rBg+1, 2) * gray; % Why 2 layers? LA (Luminance + Alpha)
    [x, y] = meshgrid(-1*rBg:1*rBg,-1*rBg:1*rBg);
    % Gaussian profile can be introduced at the 1st Luminance layer.
    mask(:, :, 2) = white * (1-(x.^2 + y.^2 <= rBg^2));
    masktex = Screen('MakeTexture', s.window, mask);

    %% jitter initial offset
    offset_Ct = [0 0];
    offset_Bg = [0 0];
    
    %% Sequence of drift speed of center object 
    % Query duration of monitor refresh interval:
    ifi = Screen('GetFlipInterval', s.window)
    % speed of grating shift
    speedseq = randi(rs, length(speed), 1, me.n_saccade);
    shiftperframe = round(speed(speedseq) * waitframes * ifi); % pixels per one stim frame
    % drifting length over one saccade
    driftL = shiftperframe * me.jumpevery;
    
    %%
    WaitStartKey(s.window);
    device_id = MyKbQueueInit; % paired with "KbQueueFlush()"
    vbl=0;
    
    %% Loop over saccades: Saccade is defined as Bg image jump
    for i = 1:me.n_saccade 
        %% Pick one BG image
        img = rescale(images{randi(rs, numimages)}); % rescale the range of values in image (function defined in the below by Lane)
        % Size check: 
        if min(size(img)) <= 2*L_Bg
            disp('! Natural image for Bg is smaller than 2 times of the patch size needed in pixels. Smaller number of pixels were selected for the patch.');
            L_Bg = floor(0.5*size(img));
        end
                    
        %% Generate a sequence of shift by jitter (estimate max shift)
        % instantaneous jitter sequence over one period of saccade. [x y]
        jitter_Bg = (randi(rs, (2*me.jitterBg+1), me.jumpevery, 2) - (me.jitterBg+1));
        jitter_Ct = (randi(rs, (2*me.jitterCt+1), me.jumpevery, 2) - (me.jitterCt+1));
        % Shift by jitter: Accumulation
        shift_Bg = cumsum(jitter_Bg);
        shift_Ct = cumsum(jitter_Ct);
        % Positive shift
        shift_Bg = shift_Bg - min(shift_Bg(:));
        shift_Ct = shift_Ct - min(shift_Ct(:));
        if me.global
            shift_Ct = shift_Bg;
        end
        
        %% texture id for Bg image
        % size of the image patch [0 L+maxshift]
        patch_Bg = 2 * img(row:(row + L_Bg(2) - 1), col:(col + L_Bg(1) - 1)) * me.contrast + (1 - me.contrast);
        patch_Bg_resize = imresize(patch_Bg, [Bg_visiblesize Bg_visiblesize]);
        tex_Natural_Bg = Screen('MakeTexture', s.window, gray * patch_Bg_resize);
        
        % resize to the
            
        %% during saccade: Saccade - control 1 - control 2 - ..(defined by 1st frame)
        for cur_frame = 1:me.jumpevery
            % offset
            offset_Bg = shift_Bg;
            offset_Ct = shift_Bg; 
            
            if me.jitter
                % Natural images: add jitter to previous position. 
                    row = mod(row + jitter_Bg(2), round(size(img,1)-L_Bg(1)));
                    col = mod(col + jitter_Bg(1), round(size(img,2)-L_Bg(2)));
            end

            %% drifting of center and bg gratings [x y]
            if me.drifting
                offset_Ct = mod(offset_Ct - round([shiftperframe(i), 0]), p);
            end
            if me.driftingBg
                offset_Bg = mod(offset_Bg - round([shiftperframe(i), 0]), p);
            end
            
            %% Texture id for natural image
            
            patch_Ct = 2 * img(row_Ct:(row_Ct + L_Ct(2) - 1), col_Ct:(col_Ct + L_Ct(1) - 1)) * me.contrast + (1 - me.contrast);
            patch_Ct_resize = imresize(patch_Ct, [Ct_visiblesize Ct_visiblesize]);
            
            tex_Natural_Ct = Screen('MakeTexture', s.window, gray * patch_Ct_resize);
            
            %% Exp: Saccade 
            if cur_frame == 1
                % Gratings: 
                    % 180 phase shift
                    offset_Bg = mod(offset_Bg + p/2., p);
                    offset_Ct = mod(offset_Ct + p/2., p);
                % Naturalistic images:
                % Bg
                    img = rescale(images{randi(rs, numimages)}); % rescale the range of values in image (function defined in the below by Lane)
                    % Size check: 
                    if min(size(img)) <= 2*L_Bg
                        disp('! Natural image for Bg is smaller than 2 times of the patch size needed in pixels. Smaller number of pixels were selected for the patch.');
                        L_Bg = floor(0.5*size(img));
                    end
                         
                    % [row col] position in the new image.~[y x] 
                    row = randi(rs, size(img,1) - 2*L_Bg(2)) + round(0.5*L_Bg(2));
                    col = randi(rs, size(img,2) - 2*L_Bg(1)) + round(0.5*L_Bg(1));

                % Ct 
                    % 1. Pick a new image and normalize
                    % 2. Change drifting speed
                    img_obj = rescale(images{randi(rs, numimages)});
                    % image size check
                    if min(size(img_obj)) <= 2*L_Ct % min = 2*patch (image size + jitter space)
                        disp('! Natural image for object at the center is smaller than 2 times of the patch size needed in pixels. Smaller number of pixels were selected for the patch.');
                        L_Ct = floor(0.5*size(img_obj));
                    end
                    % Start location                
                    row_Ct = randi(rs, size(img_obj,1) - 2*L_Ct(2)) + round(0.5*L_Ct(2));
                    col_Ct = randi(rs, size(img_obj,2) - 2*L_Ct(1)) + round(0.5*L_Ct(1));
            end
            
            %% Control exp 1: No Bg saccade
            if cur_frame == i_control_1
                % No saccade @ Bg
                % Saccade @ Ct: new image
                
                % Gratings: 
                    % 180 phase shift
                    offset_Ct = mod(offset_Ct + p/2., p);
                    
                % New image for center object    
                              
            end
            %% Control exp 2: No Bg saccade but with same image for center
            if cur_frame == i_control_2
                % No saccade @ Bg
                % Saccade @ Ct: new image
                
                % Gratings: 
                    % 180 phase shift
                    offset_Ct = mod(offset_Ct + p/2., p);
                    
                % New image for center object    
            end         
            

            %% Choose and Draw textures at Center and BG.
            if me.naturalscenes
                tex_Bg = tex_Natural_Bg;
                tex_Ct = tex_Natural_Ct;
                %offset_Bg = []; % texture will be resized to fit to destination rect size. 
            else
                tex_Bg = Bg_gratingtex;
                tex_Ct = Ct_gratingtex;
            end

            if me.off_bg
                tex_Bg = gray_tex;
            end
            % Texture for gratings has the size of [0, L+p]?
            draw_Bg_Ct_texture(s, tex_Bg, tex_Ct, masktex, Bg_visiblesize, Ct_visiblesize, offset_Bg, offset_Ct);

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
        end % loop within saccades
    end % loop for saccades
    
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