function [Ieff, Mp, MmaxOverMp, MrOverMp, thetaCap, thetaPC, thetaUlt, lambda, theta_y] = ...
    steelColumnHinge(isBox, backbone, degradation, orientation, props, LCol, Fye, Es, Pg)
% steelColumnHinge computes the properties of the monotonic backbone and the
% cyclic deterioration energy parameter for Steel wide flange columns
% ASSUMING that are symmetric (symmetric fixed-fixed beam)
%
% AISC 342-2021 
%
% ASCE/SEI 41 Seismic Evaluation and Retrofit of Existing Buildings 
%
% Per Lignos et al (2019) Proposed Updates to the ASCE 41 Nonlinear 
% Modeling Parameters for Wide-Flange Steel Columns in Support of 
% Performance-Based Seismic Engineering
%
% NIST (2017) Recommended Modeling Parameters and Acceptance Criteria for 
% Nonlinear Analysis in Support of Seismic Evaluation, Retrofit, and Design
%
% INPUTS
%   isBox       = true for box columns
%   backbone    = 'Monotonic', 'First_cycle'
%   degradation = True, False (Consider or not cyclic degradation)
%   orientation = 1 -> Strong
%                 0 -> Weak
%  props = struct with section geometrical properties
%       db          = Beam depth [in] 
%       tw          = web thickness [in]
%       bf          = beam flange width [in]
%       tf          = flange thickness [in]
%       h_tw        = web slenderness ratio
%       Sz          = section modulus in STRONG orientation [in^3]
%       Sy          = section modulus in WEAK orientation [in^3]
%       Zz          = plastic section modulus STRONG orientation [in^3]
%       Zy          = plastic section modulus WEAK orientation [in^3]
%       Ag          = gross area [in^2]
%   LCol        = column length [in]
%   Fye         = steel expected yielding stress COLUMN [ksi]
%   Es          = modulus of elasticity [ksi]
%   Pg          = Gravity axial load [kip]
%
% OUTPUTS
%   EIeff, Mp, MrOverMp, thetaCap, thetaPC, thetaUlt, lambda
% 
%%
% Read section properties
db   = props.db;
tw   = props.tw;
h_tw = props.h_tw;
bf   = props.bf;
tf   = props.tf;
Sz   = props.Sz;
Zz   = props.Zz;
Sy   = props.Sy;
Zy   = props.Zy;
Ag   = props.A;
r_y  = sqrt(props.Iy/Ag); % radius of gyration of the bare steel section in WEAK AXIS [in]

% Compute stiffness
if orientation == 1
    I = Sz*db/2;        % Assuming symmetric section
    Z = Zz;
    Aw = tw*db;
else
    I = Sy*bf/2;
    Z = Zy;
    Aw = 2*tf*bf;
end
G = Es/(2*(1+0.3)); % Shear modulus
beta = 1.00;        % overstrength factor (1.15 in reference but using MmaxOverMp is better to use 1.0 here)
Lb = LCol;          % Braced length of the column

%%%%% FLEXURAL STRENGTH CONSIDERING UNBRACED LENGTH
c     = 1; % factor for torsional stiffness (W sections use == 1)
Cb    = 2.27; % factor for moment redistribution (double curvature)
[Mn, ~] = computeMnVnSteelProfile(Es,Fye,props,Lb/12,c,Cb,orientation,isBox);
Mn = 12*Mn; % kip-in

%%%%% FLEXURAL STRENGTH CONSIDERING AXIAL LOAD
Pye = Ag*Fye;
if Pg/Pye <= 0.20
    Mp = beta*Mn*(1 - Pg/Pye);
else    
    Mp = beta*Mn*9/8*(1 - Pg/Pye);
end

% Effective Elastic stiffness (to account for shear deformation)
% compression factor for stiffness (ASCE41-17 9-5)
if Pg/Pye <= 0.5
    t_b = 1.0;
else
    t_b = 4*Pg/Pye*(1 - Pg/Pye);
end
L  = LCol/2;             % Shear spam (half the length)
Ks = G*Aw/L;             % Shear lateral stiffness of the column
Kb = 12*Es*I*t_b/LCol^3; % bending lateral stiffness of the column
Ke = Ks*Kb/(Ks+Kb);      % effective lateral stiffness
EIeff = Ke*LCol^3/12;    % effective EI to use in element without shear deformation in its formulation
Ieff = EIeff/Es;         % effective I to use in element without shear deformation in its formulation

if ~isBox
    %%%%%%%%% For Wide-Flange columns %%%%%%%%%%
    theta_y = Mp*LCol/(6*EIeff);
    if strcmp(backbone, 'NIST2017') && degradation
    %%%%%%% MONOTONIC ENVELOPE (FOR EXPLICIT CYCLIC DEGRADATION MODELS) %%%%%%%
    %%%%%%% NIST GUIDELINES 2017 %%%%%%%
        % Capping strength
        MmaxOverMp = min(max(12.5*(h_tw)^(-0.2)*(Lb/r_y)^(-0.4)*(1 - Pg/Pye)^0.4, 1.0), 1.3);
        % Residual strength
        MrOverMp = (0.5 - 0.4*Pg/Pye);
        % Deformation capacity
        thetaCap = min(294*(h_tw)^(-1.7)*(Lb/r_y)^(-0.7)*(1 - Pg/Pye)^1.6, 0.12); % upper bound modified from 0.20 to get a logical curve    
        thetaPC = min([90*(h_tw)^(-0.8)*(Lb/r_y)^(-0.8)*(1 - Pg/Pye)^2.5, 0.30]);
        thetaUlt = 0.15;
        % Cyclic detereoration parameter
        if Pg/Pye <= 0.35
            lambda = min(25000*(h_tw)^(-2.14)*(Lb/r_y)^(-0.53)*(1 - Pg/Pye)^4.92, 3.0);
        else
            lambda = min(268000*(h_tw)^(-2.30)*(Lb/r_y)^(-1.3)*(1 - Pg/Pye)^1.19, 3.0);
        end
    elseif strcmp(backbone, 'NIST2017') && ~degradation
    %%%%%%%%% FIRST-CYCLE ENVELOPE (FOR NO CYCLIC DEGRADATION MODELS) %%%%%%%%%
    %%%%%%% NIST GUIDELINES 2017 %%%%%%%
        % Capping strength
        MmaxOverMp = min(max(9.5*(h_tw)^(-0.4)*(Lb/r_y)^(-0.16)*(1 - Pg/Pye)^0.2, 1.0), 1.3);
        % Residual strength
        MrOverMp = (0.4 - 0.4*Pg/Pye);
        % Deformation capacity
        thetaUlt = 0.08*(1 - 0.6*Pg/Pye);
        thetaCap = min(15*(h_tw)^(-1.6)*(Lb/r_y)^(-0.3)*(1 - Pg/Pye)^2.3, thetaUlt*0.9); % upper bound modified from 0.10 to get a logical curve
        thetaPC = min([14*(h_tw)^(-0.8)*(Lb/r_y)^(-0.5)*(1 - Pg/Pye)^3.2, 0.10]);        

        lambda = 0;
    elseif strcmp(backbone, 'ASCE41')
    %%%% ASCE41/SEI 17 FIRST-CYCLE ENVELOPE (FOR NO CYCLIC DEGRADATION MODELS) %%%%
    %%%% Table 9-7.1
    % Assuming 0.001 as the minimum possible value for thetaCap and thetaUlt

        Mp = min(Mp/beta, Z*Fye); % ASCE41 does not use the beta overstrength factor
        theta_y = Mp*LCol/(6*EIeff);

        thetaCap1 = max(0.8*(1 - Pg/Pye)^2.2*(0.1*Lb/r_y + 0.8*h_tw)^(-1)-0.0035, 0.001);
        thetaCap2 = max(1.2*(1 - Pg/Pye)^1.2*(1.4*Lb/r_y + 0.1*h_tw + 0.9*bf/(2*tf))^(-1)-0.0023, 0.001);
        thetaUlt1 = max(7.4*(1 - Pg/Pye)^2.3*(0.5*Lb/r_y + 2.9*h_tw)^(-1)-0.006, 0.001);
        thetaUlt2 = max(2.5*(1 - Pg/Pye)^1.8*(0.1*Lb/r_y + 0.2*h_tw + 2.7*bf/(2*tf))^(-1)-0.0097, 0.001);
        MrOverMp1 = 0.9 - 0.9*Pg/Pye;
        MrOverMp2 = 0.5 - 0.5*Pg/Pye;

        h_tw_1 = 2.45*sqrt(Es/Fye)*(1-0.71*Pg/Pye);
        h_tw_2 = max(0.77*sqrt(Es/Fye)*(2.93-Pg/Pye), 1.49*sqrt(Es/Fye));
        h_tw_3 = 3.76*sqrt(Es/Fye)*(1-1.83*Pg/Pye);
        h_tw_4 = min(1.12*sqrt(Es/Fye)*(2.33-Pg/Pye), 1.49*sqrt(Es/Fye));
        if bf/(2*tf) <= 0.3*sqrt(Es/Fye) && Pg/Pye < 0.2 && h_tw <= h_tw_1
            thetaCap = thetaCap1;
            thetaUlt = thetaUlt1;
            MrOverMp = MrOverMp1;
        elseif bf/(2*tf) <= 0.3*sqrt(Es/Fye) && Pg/Pye >= 0.2 && h_tw <= h_tw_2
            thetaCap = thetaCap1;
            thetaUlt = thetaUlt1;
            MrOverMp = MrOverMp1;
        elseif bf/(2*tf) >= 0.38*sqrt(Es/Fye) && Pg/Pye < 0.2 && h_tw >= h_tw_3
            thetaCap = thetaCap2;
            thetaUlt = thetaUlt2;
            MrOverMp = MrOverMp2;
        elseif bf/(2*tf) >= 0.38*sqrt(Es/Fye) && Pg/Pye >= 0.2 && h_tw >= h_tw_4
            thetaCap = thetaCap2;
            thetaUlt = thetaUlt2;
            MrOverMp = MrOverMp2;
        else
            thetaCap_a = interp1([-1000, 0.3*sqrt(Es/Fye), 0.38*sqrt(Es/Fye), 1000], [thetaCap1, thetaCap1, thetaCap2, thetaCap2], bf/(2*tf));
            thetaUlt_a = interp1([-1000, 0.3*sqrt(Es/Fye), 0.38*sqrt(Es/Fye), 1000], [thetaUlt1, thetaUlt1, thetaUlt2, thetaUlt2], bf/(2*tf));
            if Pg/Pye < 0.2
                thetaCap_b = interp1([-1e6, h_tw_1, h_tw_3, 1e6], ...
                    [thetaCap1, thetaCap1, thetaCap2, thetaCap2], h_tw);
                thetaUlt_b = interp1([-1e6, h_tw_1, h_tw_3, 1e6], ...
                    [thetaUlt1, thetaUlt1, thetaUlt2, thetaUlt2], h_tw);
            else
                thetaCap_b = interp1([-1e6, min(h_tw_2,h_tw_4), max(h_tw_2,h_tw_4), 1e6], ...
                    [thetaCap1, thetaCap1, thetaCap2, thetaCap2], h_tw);
                thetaUlt_b = interp1([-1e6, min(h_tw_2,h_tw_4), max(h_tw_2,h_tw_4), 1e6], ...
                    [thetaUlt1, thetaUlt1, thetaUlt2, thetaUlt2], h_tw);
            end
            thetaCap = min(thetaCap_a, thetaCap_b);
            thetaUlt = min(thetaUlt_a, thetaUlt_b);
            MrOverMp = MrOverMp2;
        end

        thetaPC = 3*(thetaUlt - thetaCap)/4; % assumed to avoid convergence issues
        if Pg/Pye < 0.2
            MmaxOverMp = (1 + 0.03*thetaCap/theta_y); % hardening slope 3% per ASCE 41
        else
            MmaxOverMp = (1 + 0.01*thetaCap/theta_y); % hardening slope 1% per ASCE 41
        end
        lambda = 0;
    elseif strcmp(backbone, 'AISC342')
    %%%% AISC342 2021 FIRST-CYCLE ENVELOPE (FOR NO CYCLIC DEGRADATION MODELS) %%%%
    %%%% Table C3.6
    % Assuming 0.001 as the minimum possible value for thetaCap and thetaUlt                
    
        Mp = min(Mp/beta, Z*Fye); % ASCE41 and AISC342 do not use the beta overstrength factor
        theta_y = Mp*LCol/(6*EIeff);
        
        % Compute slenderness limits for the web (Table D1.1 AISC 341-16)
        Ca = Pg/Pye;
        if Ca < 0.114
            lamda_hd = 2.57*sqrt(Es/Fye)*(1-1.04*Ca);
            lamda_md = 3.96*sqrt(Es/Fye)*(1-3.04*Ca);
        else
            lamda_hd = max(0.88*sqrt(Es/Fye)*(2.68-Ca), 1.57*sqrt(Es/Fye));
            lamda_md = max(1.29*sqrt(Es/Fye)*(2.12-Ca), 1.57*sqrt(Es/Fye));
        end        
        if lamda_hd > lamda_md
            error('ERROR: lamda_hd must be greater than lambda_md')
        end
        
        % Compute backbone parameters
        if h_tw < lamda_hd
            % highly ductile sections
            thetaCap = min(5.5*h_tw^(-0.95)*(Lb/r_y)^(-0.5)*(1-Ca)^2.4, 0.07);
            thetaUlt = min(20*h_tw^(-0.9)*(Lb/r_y)^(-0.5)*(1-Ca)^3.4, 0.07);
            MrOverMp = 0.4 - 0.4*Ca;
        elseif h_tw >= lamda_md
            % not moderately ductile sections
            thetaCap = max(1.2*(1-Ca)^1.2*(1.4*Lb/r_y + 0.1*h_tw + 0.9*bf/(2*tf))^(-1) - 0.0023, 0.0001);
            thetaUlt = max(2.5*(1-Ca)^1.8*(0.1*Lb/r_y + 0.2*h_tw + 2.7*bf/(2*tf))^(-1) - 0.0097, 0.0001);
            MrOverMp = 0.5 - 0.5*Ca;
        else
            % moderately ductile
            thetaCap1 = min(5.5*h_tw^(-0.95)*(Lb/r_y)^(-0.5)*(1-Ca)^2.4, 0.07);
            thetaUlt1 = min(20*h_tw^(-0.9)*(Lb/r_y)^(-0.5)*(1-Ca)^3.4, 0.07);
            MrOverMp1 = 0.4 - 0.4*Ca;
            
            thetaCap2 = max(1.2*(1-Ca)^1.2*(1.4*Lb/r_y + 0.1*h_tw + 0.9*bf/(2*tf))^(-1) - 0.0023, 0.0001);
            thetaUlt2 = max(2.5*(1-Ca)^1.8*(0.1*Lb/r_y + 0.2*h_tw + 2.7*bf/(2*tf))^(-1) - 0.0097, 0.0001);
            MrOverMp2 = 0.5 - 0.5*Ca;
            
            thetaCap = interp1([-1000, lamda_hd, lamda_md, 1000], ...
                [thetaCap1, thetaCap1, thetaCap2, thetaCap2], h_tw);
            thetaUlt = interp1([-1000, lamda_hd, lamda_md, 1000], ...
                [thetaUlt1, thetaUlt1, thetaUlt2, thetaUlt2], h_tw);  
            MrOverMp = interp1([-1000, lamda_hd, lamda_md, 1000], ...
                [MrOverMp1, MrOverMp1, MrOverMp2, MrOverMp2], h_tw);
        end

        thetaPC = 3*(thetaUlt - thetaCap)/4; % assumed to avoid convergence issues
        if Pg/Pye < 0.2
            MmaxOverMp = (1 + 0.03*thetaCap/theta_y); % hardening slope 3% per ASCE 41
        else
            MmaxOverMp = (1 + 0.01*thetaCap/theta_y); % hardening slope 1% per ASCE 41
        end
        lambda = 0;        
    end
else
    %%%%%%%%% For Built-up Box columns %%%%%%%%%%
    %%% AISC 342-2021 (IN REVIEW) IS THE ONLY SPECS AVAILABLE %%%     
    %%% Table C3.6: lambda = h_tw (calculated with clear distances as in 
    %%% function getSectionProperties)
    
    Mp = min(Mp/beta, Z*Fye); % ASCE41 and AISC342 do not use the beta overstrength factor
    theta_y = Mp*LCol/(6*EIeff);
    
    factorBuiltUp = 0.75;
        
    thetaCap = factorBuiltUp*min(1.1*h_tw^(-1.2)*(1 - Pg/Pye)^1.8, 0.05);
    thetaUlt = factorBuiltUp*max(min(0.5*h_tw^(-0.6)*(1 - Pg/Pye)^1.2-0.01, 0.08), 0.0001);
    if thetaUlt < thetaCap
        thetaUlt = thetaCap + theta_y; % assumed to avoid convergence issues  
    end
    MrOverMp = factorBuiltUp*0.25;       
    
    thetaPC = 3*(thetaUlt - thetaCap)/4; % assumed to avoid convergence issues    
    if Pg/Pye < 0.2
        MmaxOverMp = (1 + 0.03*thetaCap/theta_y); % hardening slope 3% per ASCE 41
    else
        MmaxOverMp = (1 + 0.01*thetaCap/theta_y); % hardening slope 1% per ASCE 41
    end
    lambda = 0;  
        
end

% figure
% fontSize = 12;
% x = [0, theta_y, theta_y+thetaCap, theta_y+thetaCap, theta_y+thetaUlt, theta_y+thetaUlt];
% y = [0, Mp, Mp*MmaxOverMp, MrOverMp*Mp, MrOverMp*Mp, 0];
% plot(x, y, 'linewidth', 3)
% xlabel('Rotation [rad]')
% ylabel('Moment [kip-in]')
% xlim([0, 0.16])
% PlotGrayScaleForPaper(-999,'vertical','',[0.5 1],'normal',fontSize)

end