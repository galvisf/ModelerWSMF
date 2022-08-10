function sigcr = fractureModelPropsSplice(cvn, a0, Es, FyCol, db, tf)
% The mode I stress intensity factor (K_IC)
% 
% INPUTS
%   cvn       = Charpy-V-Notch thoughness tests at service temperature (70 F)
%   a0        = length of the flange NOT welded [in]
%   Es        = Steel elastic modulus in [ksi]
%   FyCol     = Column steel yielding stress [ksi]
%   db        = column depth [in]
%   tf        = column flange thickness [in]
%         
%%
b = 0.02; % post-yielding stiffness ration
FuCol = min(1.5*FyCol, 70); % Lesser of base metal or weld metal static ultimate strength

% Fracture thoughness
alpha = 7.6;
T_service = 70;
[k_ic_median, ~, ~] = K_IC(cvn, FyCol, alpha, T_service, Es);

% Yielding strength on weld to develop Mp in section
e_y = FyCol/Es; % strain to yield
phi_p = e_y; % curvature to yield at 1.0in from neutral axis
e_flange = phi_p*(db - tf)/2; % strain at flange fiber to ensure web yielding
delta_stress = e_flange*b*Es;
FpCol = FyCol + delta_stress; % Flange stress to ensure web yielding

% Sigma critical
F_a0 = (2.3 - 1.6*a0/tf)*4.6*a0/tf;
sigcr = min([k_ic_median/(F_a0*sqrt(pi*a0)), FpCol, FuCol*(1 - a0/tf)]);

end
