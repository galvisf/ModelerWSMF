function Fx = EQ_UBC1973(bldgData, Z, frameType)
%
% INPUTS
%   bldgData  = struct with all the data for the frame
%   Z         = Seismic zone factor
%   frameType = 'Space' for ductile space frames
%               'Perimeter'
%               'Intermediate'
%
%% Read relevant variables 
floorNum = bldgData.floorNum;
storyHgt = bldgData.storyHgt;
bayLgth  = bldgData.bayLgth;

weightFloor = (sum(bldgData.wgtOnBeam,2) + sum(bldgData.wgtOnCol,2) + bldgData.wgtOnEGF);
D = sum(bayLgth);
H = sum(storyHgt);

%% Lateral load UBC (1973)

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
Ds = sum(bayLgth);
Ft = 0.004*Vs*(sum(storyHgt)/Ds)^2;
Fx = (Vs - Ft)*weightFloor.*cumsum(storyHgt)./sum(weightFloor.*cumsum(storyHgt));
Fx(end) = Fx(end) + Ft;

% Save lateral load patter file
fid_r = fopen('EQ_UBC1973.tcl', 'wt');
fprintf(fid_r, 'set iFi {\n');
Fx_norm = Fx;
for i = 1:length(Fx)
    fprintf(fid_r, '\t%f\n', Fx_norm(i));
end
fprintf(fid_r,'}');
fclose(fid_r);

end