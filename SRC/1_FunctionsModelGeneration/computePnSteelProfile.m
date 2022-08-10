% computePnSteelProfile
% 
% INPUTS
%   Es    = [ksi]
%   Fy    = [ksi]
%   props = [in]
%   Lb    = [ft]
%   c     = 1; % factor for torsional stiffness (W sections use == 1)
%   Cb    = 1; % factor for moment redistribution (simply supported beam == 1)
%
% OUTPUTS
%   Mn    = [kip-ft]
%   Vn    = [kip]
%
function Pn = computePnSteelProfile(Es,Fy,k,props,Lc)

    % Read section properties
    Ag = props.A;
    ry = sqrt(props.Iy/Ag);
    
    Lc = Lc * 12; % unbraced length [in]
    
    % Axial capacity
    slenderness = k*Lc/ry;
    Fe = pi^2*Es/slenderness^2;
    if slenderness < 4.71*sqrt(Es/Fy)
        Pn = Ag*Fy*0.658^(Fy/Fe);
    else
        Pn = 0.877*Fe;
    end
    
end
