function Fx = EQ_UBC1982(bldgData, Z, Ts, I, frameType)
%
% INPUTS
%   bldgData  = struct with all the data for the frame
%   Z         = Seismic zone factor
%   Ts        = Soil column fundamental vibration period [s]
%   I         = importance factor
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

% Structural system factor
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

% Soil amplification factor
if T/Ts <= 1
    S = 1 + T/Ts - 0.5*(T/Ts)^2;
else
    S = 1.2 + 0.6*T/Ts - 0.3*(T/Ts)^2;
end

% Period factor
C = min(0.12, 1/(15*T^(1/2)));
CS = min(C*S, 0.14);

% Base shear
Vs = Z*I*K*CS*sum(weightFloor);

% Vertical distribution of lateral force
Ft = min(0.07*T*Vs, 0.25*Vs);
Fx = (Vs - Ft)*weightFloor.*cumsum(storyHgt)./sum(weightFloor.*cumsum(storyHgt));
Fx(end) = Fx(end) + Ft;

% Save lateral load patter file
fid_r = fopen('EQ_UBC1982.tcl', 'wt');
fprintf(fid_r, 'set iFi {\n');
Fx_norm = Fx;
for i = 1:length(Fx)
    fprintf(fid_r, '\t%f\n', Fx_norm(i));
end
fprintf(fid_r,'}');
fclose(fid_r);

end