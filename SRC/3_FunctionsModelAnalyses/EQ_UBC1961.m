function Fx = EQ_UBC1961(bldgData, Z, frameType)
%
% INPUTS
%   bldgData  = struct with all the data for the frame
%   Z         = Seismic zone factor
%   frameType = 'Space' for ductile space frames
%               'Perimeter'
%               'Intermediate'
%
%% Read relevant variables 
storyHgt = bldgData.storyHgt;
bayLgth  = bldgData.bayLgth;
floorNum = bldgData.floorNum;

weightFloor = (sum(bldgData.wgtOnBeam,2) + sum(bldgData.wgtOnCol,2) + bldgData.wgtOnEGF);
D = sum(bayLgth);
H = sum(storyHgt);

%% Lateral load UBC (1961)

% Structural system factor and approx. period
% if strcmp(frameType, 'Space')
% Ductile space frames
K = 0.67;
N_floors = floorNum;
T = 0.1*N_floors;
% else
%     % All other frames (perimeter and intermediate)
%     K = 1.00;
%     T = 0.05*H/sqrt(D);
% end

% Period factor
C = 0.05/(T^(1/3));

% Base shear
Vs = Z*K*C*sum(weightFloor);

% Vertical distribution of lateral force
if H/D > 5
    Ft = 0.1*Vs;
else
    Ft = 0;
end
Fx = (Vs - Ft)*weightFloor.*cumsum(storyHgt)./sum(weightFloor.*cumsum(storyHgt));
Fx(end) = Fx(end) + Ft;

% Save lateral load patter file
fid_r = fopen('EQ_UBC1961.tcl', 'wt');
fprintf(fid_r, 'set iFi {\n');
Fx_norm = Fx;
for i = 1:length(Fx)
    fprintf(fid_r, '\t%f\n', Fx_norm(i));
end
fprintf(fid_r,'}');
fclose(fid_r);

end