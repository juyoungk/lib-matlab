function [stim] = annulusNoiseGen(varargin)
    % 
    p=ParseInput(varargin{:});
    %
    centerX = p.Results.centerX;    %offset from the center
    centerY = p.Results.centerY;
    stimFrameInterval = p.Results.stimFrameInterval;
    seed = p.Results.seed;
    duration = p.Results.DurationSecs;
    contrast = p.Results.objContrast;
try
    % frame parameters
    vbl = 0; vbl_prev =0; stop =0;
   
    radiusNoise = Pixel_for_Micron( linspace(200, 800, 7) );
     widthNoise = Pixel_for_Micron( 50 );
    % anuulus noise
    NoiseDuration = 300; seed = 0; 

    stim = AnnulusGNoiseGen(contrast, NoiseDuration, stimFrameInterval, seed, centerX, centerY, radiusNoise, widthNoise);
       
catch exception
    %this "catch" section executes in case of an error in the "try" section
    %above. Importantly, it closes the onscreen window if its open.
    CleanAfterError();
    rethrow(exception);
end %try..catch..
end


function stim = AnnulusGNoiseGen(contrast, duration, stimFrameInterval, seed, ...
                            centerX, centerY, radius, annulusWidth, varargin)
p = ParseInput(varargin{:});
log = addLog(p.Results.log);

% init random seed generator
randomStream = RandStream('mcg16807', 'Seed', seed);

% Nominal-rate-optimized stimulus frame
frameTime = 0.033229;
framesN = round( duration / frameTime );

stim = zeros(length(radius), framesN);
for i=1:framesN
    for j=1:length(radius)
        %
        stim(j,i) = randn(randomStream, 1);
        % 3*sigma = gray (mean)? 
        % ~35% of the max contrast of binary noise
        % Uniform dist = 14% of the max contrast of binary noise
        % Contrast here? = sqrt of variance
    end
    
end

end

function [outer_rect, inner_rect] = annulusRect(radius, annulusWidth, screen, centerX, centerY)
    outer_radius = radius + annulusWidth/2.;
    inner_radius = radius - annulusWidth/2.;
    
    outer_rect = RectForScreen(screen, 2*outer_radius, 2*outer_radius, centerX, centerY);
    inner_rect = RectForScreen(screen, 2*inner_radius, 2*inner_radius, centerX, centerY);
end

function p =  AnnulusParseInput(varargin)
    p  = inputParser;   % Create an instance of the inputParser class.
    p.addParameter('centerX', 0, @(x) isnumeric(x));
    p.addParameter('centerY', 0, @(x) isnumeric(x));
    p.addParameter('radius', 100, @(x) isnumeric(x));
    p.addParameter('AnnulusWidth', 10, @(x) x>0);
    p.addParameter('annColor', 128, @(x) x>0);
    p.addParameter('bgColor', 0, @(x) x>0);
end

function p =  ParseInput(varargin)
    % Generates a structure with all the parameters
    % Allowed parameters are:
    %
    % objContrast, objJitterPeriod, objSeed, stimSize, objSizeH, objSizeV,
    % objCenterXY, backContrast, backJitterPeriod, presentationLength,
    % movieDurationSecs, pdStim, debugging, barsWidth, waitframes, vbl

    % In order to get a parameter back just use
    %   p.Resulst.parameter
    % In order to display all the parameters use
    %   disp 'List of all arguments:'
    %   disp(p.Results)
    %
    % General format to add inputs is...
    % p.addRequired('script', @ischar);
    % p.addOptional('format', 'html', ...
    %     @(x)any(strcmpi(x,{'html','ppt','xml','latex'})));
    % p.addParamValue('outputDir', pwd, @ischar);
    % p.addParamValue('maxHeight', [], @(x)x>0 && mod(x,1)==0);

    p  = inputParser;   % Create an instance of the inputParser class.

    p.addParameter('centerX', 0, @(x) isnumeric(x));
    p.addParameter('centerY', 0, @(x) isnumeric(x));
    p.addParameter('radius', 100, @(x) isnumeric(x));
    p.addParameter('rotationAngle', 0, @(x) x>=0 && x <=360);
    p.addParameter('objContrast', 1, @(x) x>=0 && x <=1);
    % 
    p.addParameter('DurationSecs', 15, @(x)x>0);
    p.addParameter('Ncycle', 10, @(x)x>0);
    p.addParameter('halfPeriodSecs', 2, @(x)x>0);
    %
    p.addParameter('seed', 1, @(x) isnumeric(x));
    p.addParameter('debugging', 0, @(x) x>=0 && x <=1);
    p.addParameter('log', [], @(x) ischar(x));
    %
    p.addParameter('stimFrameInterval', 0.033, @(x)x>=0);
    %
    p.addParameter('array_type', 'HiDens_v3', @(x) ischar(x));   % in what units?
    % Call the parse method of the object to read and validate each argument in the schema:
    p.parse(varargin{:});
end

