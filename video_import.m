%%
vid = VideoReader('BBC south korea.mp4');

%%
vidHeight = vid.Height;
vidWidth = vid.Width;

% NOTE: why struct for each frame? Very convinient to append frames. No need
% to carefully match dimensions. 

mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
'colormap',[]);

% Define the 1st struct object. Then, the field (e.g. 'colormap') will continue even for
% appended object.

%% 
numFrame = 50;
k = 1;
while hasFrame(vid)
    mov(k).cdata = readFrame(vid);
    
    if k == numFrame
        break;
    end
    k = k+1;
end

%% Color adjust for Mouse cones.
% Inversely convert CIE's color matching functions

% Convolution with mouse cones

