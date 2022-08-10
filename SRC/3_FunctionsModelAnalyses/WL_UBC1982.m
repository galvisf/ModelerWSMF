function WL = WL_UBC1982(bldgData, numMRF, frameWidth, bws, exposure, I)
%
% INPUTS
%   bldgData   = struct with all the data for the frame
%   numMRF     = vector with the number of parallel frames resisting lateral load in each story
%   frameWidth = vector with the width of the building normal to the wind direction [ft]
%   bws        = basic wind speed [mph]
%   exposure   = exposure terrain for wind
%                 'C': severe exposure, flat and open terrain 0.5 miles from
%                      the site.
%                 'B': terrain with buildings, forest, or irregular surface
%                      20ft or more in height covering at least 20% of the area
%                      1.0 mile or more around the building.
%   I          = importance factor for the building
%
% OUTPUT
%   WL         = vector with the wind force to the frame in each floor [kip]
%
%% Read relevant variables 
storyHgt = bldgData.storyHgt;
tribAreaPerFrame = storyHgt/12.*(frameWidth./numMRF)'; % tributary area per frame in ft^2

%% Lateral WL UBC (1982)
% wind stagnation pressute (qs) at standard height of 30ft
switch bws
    case 70
        qs = 13;
    case 80
        qs = 17;
    case 90
        qs = 21;
    case 100
        qs = 26;
    case 110
        qs = 31;
    case 120
        qs = 37;
    otherwise
        qs = 44;
end

% combined heigh, exposure, and gust factor coefficient (Ce)
cumHeightLimits = [20,40,60,100,150,200,300,400]; % [ft]
if exposure == 'C'
    Ce = [1.2,1.3,1.5,1.6,1.8,1.9,2.1,2.2];
else
    Ce = [0.7,0.8,1.0,1.1,1.3,1.4,1.6,1.8];
end

% Pressure coefficients (Cq) - Method 1 (Normal force method)
Cq = 0.8 + 0.5; % for primary frames and systems

% design wind pressure: p = Ce*Cq*qs*I
WLsq = zeros(length(storyHgt),1); % wind load per ft^2 of vertical area
cumHgt = cumsum(storyHgt/12); % cummulative height in ft

numChanges = min(sum(cumHeightLimits < cumHgt(end)) + 1, length(cumHeightLimits));
for i = 1:numChanges
    if i == 1
        WLsq(cumHgt < cumHeightLimits(i)) = Ce(i);
    elseif i < length(cumHeightLimits)    	
        WLsq(and(cumHgt >= cumHeightLimits(i-1), cumHgt < cumHeightLimits(i))) = Ce(i);
    else
        WLsq(cumHgt >= cumHeightLimits(end-1)) = Ce(end);
    end
end
WLsq = WLsq*Cq*qs*I; % [lb/ft^2]
WL = WLsq.*tribAreaPerFrame/1000; % kip

% Save lateral load patter file
fid_r = fopen('WL_UBC1982.tcl', 'wt');
fprintf(fid_r, 'set iFi {\n');
Fx_norm = WL;
for i = 1:length(WL)
    fprintf(fid_r, '\t%f\n', Fx_norm(i));
end
fprintf(fid_r,'}');
fclose(fid_r);

end