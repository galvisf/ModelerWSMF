function WL = WL_UBC1961_1973(bldgData, numMRF, frameWidth, wpa)
%
% INPUTS
%   bldgData   = struct with all the data for the frame
%   numMRF     = vector with the number of parallel frames resisting lateral load in each story
%   frameWidth = vector with the width of the building normal to the wind direction [ft]
%   wpa        = wind pressure area
%
% OUTPUT
%   WL         = vector with the wind force to the frame in each floor [kip]
%
%% Read relevant variables 
storyHgt = bldgData.storyHgt;

tribAreaPerFrame = storyHgt/12.*(frameWidth./numMRF)'; % tributary area per frame in ft^2

%% Lateral WL UBC (1961, 1973)
WLsq = zeros(length(storyHgt),1); % wind load per ft^2 of vertical area
cumHgt = cumsum(storyHgt/12); % cummulative height in ft

% Wind Pressure Area pressures
cumHeightLimits = [30,50,100,500,1199,1200]; % [ft]
switch wpa
    case 20
        Ce = [15,20,25,30,35,40];
    case 25
        Ce = [20,25,30,40,45,50];
    case 30
        Ce = [25,30,40,45,55,60];
    case 35
        Ce = [25,35,45,55,60,70];
    case 40
        Ce = [30,40,50,60,70,80];
    case 45
        Ce = [35,45,55,70,80,90];
    otherwise
        Ce = [40,50,60,75,90,100];
end

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

WL = WLsq.*tribAreaPerFrame/1000; % kip

% Save lateral load patter file
fid_r = fopen('WL_UBC1961_1973.tcl', 'wt');
fprintf(fid_r, 'set iFi {\n');
Fx_norm = WL;
for i = 1:length(WL)
    fprintf(fid_r, '\t%f\n', Fx_norm(i));
end
fprintf(fid_r,'}');
fclose(fid_r);

end