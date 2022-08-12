function [Ieff, Mp, MmaxOverMp, MrOverMp, thetaCap, thetaPC, thetaUlt, lambda, theta_y, f_adjust] = ...
    steelBeamHinge(backbone, connType, degradation, props, Lb, Lbeam, FyBeam, Es, ...
    dc, twc, tcf, tcont, h, nBeams, FyCol)
% steelBeamHinge computes the properties of the monotonic backbone and the
% cyclic deterioration energy parameter for Steel wide flange beams ASSUMING 
% THE BEAM IS FIXED-FIXED
%
% AISC 342-2021 
%
% ASCE/SEI 41 Seismic Evaluation and Retrofit of Existing Buildings 
%
% Per Lignos and Krawinkler (2011) Deterioration Modeling of Steel 
% Components in Support of Collapse Prediction of Steel Moment Frames under 
% Earthquake Loading
%
% NIST (2017) Recommended Modeling Parameters and Acceptance Criteria for 
% Nonlinear Analysis in Support of Seismic Evaluation, Retrofit, and Design
%
% INPUTS
%   backbone    = 'NIST2017_Monotonic', 'NIST2017_First_cycle', 'ASCE41', 'AISC342'
%   connType    = 'RBS', 'non_RBS', 'PN'
%   degradation = True, False (Consider or not cyclic degradation)
%   props = struct with section geometrical properties
%       db          = Beam depth [in]
%       tw          = web thickness [in]
%       h_tw        = web slenderness ratio
%       bf          = beam flange width [in]
%       tf          = flange thickness [in]
%       A           = gross area of the section [in^2]
%       Sz          = section modulus [in^3]
%       Zz          = plastic section modulus [in^3]
%       Lbeam       = beam length at the column face [in]
%       FyBeam      = steel yielding stress [ksi]
%       Es          = modulus of elasticity [ksi]
%   Lb          = unblaced length of the beam [in] (assumed 4.5m per AISC 341 seismic design guidelines)
%   Lbeam       = beam length for stiffness calculations [in]
%
%   ONLY FOR ASCE 41 and AISC 342:
%   dc          = column depth [in]
%   twc         = Panel zone tickness (including doubler plates) [in];
%   tcf         = column flange thickness [in]
%   tcont       = continuity plate thickness [in]
%   h           = average story height [in]\
%   nBeams      = Number of beams framing in the connections
%                 1.0 for exterior connections
%                 2.0 for exterior connections
%   FyCol       = column yielding stress [ksi]
%
% OUTPUTS
%   Ieff, Mp, MrOverMp, thetaCap, thetaPC, thetaUlt, lambda, theta_y,
%   f_adjust  = array of the adjustment factors per ASCE41 and AISC342 for
%               pre-Northridhe WUF connections
%               [f_cp, f_pz, f_std, f_slen]
%               f_cp   = factor for continuity plate and column flange
%                        stiffness
%               f_pz   = factor for panel zone streength
%               f_std  = factor for span-to-depth ratio
%               f_slen = factor for beam slenderness
% 
%%
% Read section properties
db   = props.db;
tw   = props.tw;
h_tw = props.h_tw;
bf   = props.bf;
tf   = props.tf;
r_y  = sqrt(props.Iy/props.A); % radius of gyration of the bare steel section in WEAK AXIS [in]
Sz   = props.Sz;
Zz   = props.Zz;

% Basic calculations
Iz = Sz*db/2;       % Assuming symmetric section
G = Es/(2*(1+0.3)); % Shear modulus

% Effective Elastic stiffness (to account for shear deformation) - ASSUMED
% BEAM IS FIXED-FIXED
Aw = tw*db;
L = Lbeam/2;             % Shear spam (half the length)
Ks = G*Aw/L;             % Shear lateral stiffness of the column
Kb = 12*Es*Iz/Lbeam^3;   % bending lateral stiffness of the column
Ke = Ks*Kb/(Ks+Kb);      % effective lateral stiffness
EIeff = Ke*Lbeam^3/12;   % effective EI to use in element without shear deformation in its formulation
Ieff = EIeff/Es;          % effective I to use in element without shear deformation in its formulation
%%%%% 

%%%%% REDUCE CAPACITY IF RBS
if strcmp(connType, 'RBS')
    fracCut = 0.40; % fraction of the flange width cutted in the RBS
    Zz = Zz - fracCut*bf*tf*(db-tf);
end

%%%%% FLEXURAL STRENGTH CONSIDERING UNBRACED LENGTH
c     = 1; % factor for torsional stiffness (W sections use == 1)
Cb    = 2.27; % factor for moment redistribution (double curvature)
orientation = 1; % strong always for beams
isBox = false; % only support wide-flange beam sections
[Mn, ~] = computeMnVnSteelProfile(Es,FyBeam,props,Lb/12,c,Cb,orientation,isBox);
Mn = 12*Mn; % kip-in

%%%%% 
if strcmp(backbone, 'NIST2017') && degradation
%%%%%%% MONOTONIC ENVELOPE (FOR EXPLICIT CYCLIC DEGRADATION MODELS) %%%%%%%    
    if strcmp(connType, 'RBS')
        % Post-Northridge RBS (model using IMK)
        beta = 1.0; % strain-hardening factor (1.10 in reference but using MmaxOverMp is better to use 1.0 here)
        Mp = beta*Mn;
        thetaCap = 0.09*(h_tw)^(-0.3)*(bf/(2*tf))^(-0.1)*(L/db)^0.1*(db/21)^(-0.8);
        thetaPC = 6.5*(h_tw)^(-0.5)*(bf/(2*tf))^(-0.9); 
        thetaUlt = 0.20;
        MrOverMp = 0.40;
        lambda = 585*(h_tw)^(-1.14)*(bf/(2*tf))^(-0.632)*(FyBeam/51.5)^(-0.391);
    elseif strcmp(connType, 'non_RBS')
        % Post-Northridge non-RBS (model using IMK)
        beta = 1.0; % strain-hardening factor (1.20 in reference but using MmaxOverMp is better to use 1.0 here)
        Mp = beta*Mn;
        thetaCap = 0.07*(h_tw)^(-0.3)*(bf/(2*tf))^(-0.1)*(L/db)^0.3*(db/21)^(-0.7); 
        thetaPC = 4.6*(h_tw)^(-0.5)*(bf/(2*tf))^(-0.8)*(db/21)^(-0.3);        
        thetaUlt = 0.20;
        MrOverMp = 0.40;
        if db >= 21
            lambda = 536*(h_tw)^(-1.26)*(bf/(2*tf))^(-0.525)*(FyBeam/51.5)^(-0.291);
        else
            lambda = 495*(h_tw)^(-1.34)*(bf/(2*tf))^(-0.595)*(FyBeam/51.5)^(-0.360);
        end
    else
        error('For pre-Northridge use backbone = First_cycle')
    end
    MmaxOverMp = 1.2;
    f_adjust = NaN;
elseif strcmp(backbone, 'NIST2017')
%%%%%%%%% FIRST-CYCLE ENVELOPE (FOR NO CYCLIC DEGRADATION MODELS) %%%%%%%%%   
    if strcmp(connType, 'RBS')
        % Post-Northridge RBS (model using IMK)
        beta = 1.0; % (1.10 in reference but using MmaxOverMp is better to use 1.0 here)
        Mp = beta*Mn;
        thetaUlt = 0.08;
        thetaCap = min(0.55*(h_tw)^(-0.5)*(bf/(2*tf))^(-0.7)*(Lb/r_y)^(-0.5)*(L/db)^0.8, 0.07); % upper bound to ensure logical backbone        
        thetaPC = min(20*(h_tw)^(-0.8)*(bf/(2*tf))^(-0.1)*(Lb/r_y)^(-0.6), thetaUlt - thetaCap);
        MrOverMp = 0.30;  
        MmaxOverMp = 1.15;
    elseif strcmp(connType, 'non_RBS')
        % Post-Northridge non-RBS (model using IMK)
        beta = 1.0; % (1.10 in reference but using MmaxOverMp is better to use 1.0 here)
        Mp = beta*Mn;   
        thetaUlt = 0.08;
        thetaCap = min(0.3*(h_tw)^(-0.3)*(bf/(2*tf))^(-1.7)*(Lb/r_y)^(-0.2)*(L/db)^1.1, 0.07); % upper bound to ensure logical backbone;
        thetaPC = min(24*(h_tw)^(-0.9)*(bf/(2*tf))^(-0.2)*(Lb/r_y)^(-0.5), thetaUlt - thetaCap);        
        MrOverMp = 0.30;
        MmaxOverMp = 1.2;
    else
        % Pre-Northridge (model as non-deterorating IMK or histeretic hinge)
        if db >= 21
            Mp = min(Sz*FyBeam, Mn);
        else
            beta = 1.0; % (1.10 in reference but using MmaxOverMp is better to use 1.0 here)
            Mp = beta*Mn;
        end
        if db >= 24
            thetaCap = 0.008;
            thetaUlt = 0.035;
            thetaPC = min(0.035 - 0.0006*db, thetaUlt - thetaCap); % upper bound to ensure logical backbone;         
        else
            thetaCap = 0.046 - 0.0013*db;
            thetaUlt = 0.05;
            thetaPC = min(-0.003 + 0.0007*db, thetaUlt - thetaCap); % upper bound to ensure logical backbone;
        end
        MrOverMp = 0.20;        
        MmaxOverMp = 1.1;
    end    
    lambda = 0;
    f_adjust = NaN;
elseif strcmp(backbone, 'ASCE41')
%%%% ASCE41-17 FIRST-CYCLE ENVELOPE (FOR NO CYCLIC DEGRADATION MODELS) %%%%
% Assuming theta_y as the minimum possible value for thetaCap and thetaUlt

    % Beam strength
    Mp = min(Zz*FyBeam, Mn);
    My = min(Sz*FyBeam, Mn);
    
    % Correction factor due to continuity plate (ASCE41 9.4.2.4.3)
    if tcf >= bf/5.2 || (tcf >= bf/7 && tcf < bf/5.2 && tcont >= tf/2) || (tcf < bf/7 && tcont >= tf)
        f_cp = 1.0;
    else
        f_cp = 0.8;
    end
    % Correction factor due to panel zone    
    L = Lbeam + 2*dc;
    Vpz = nBeams*My/db*(L/(L - dc))*(h - db)/h;
    Vy = 0.6*FyCol*dc*twc;
    if Vpz/Vy <= 0.9 && Vpz/Vy >= 0.6 || h == 0
        f_pz = 1.0;
    else
        f_pz = 0.8;
    end
    % Correction factor due to clear span-to-depth ratio
    if Lbeam/db <= 8
        f_std = 0.5^((8-Lbeam/db)/3);
    else
        f_std = 1.0;
    end
    % Correction factor due to beam flange and web slenderness
    if bf/(2*tf) < 0.3*sqrt(Es/FyBeam) && h_tw < 2.45*sqrt(Es/FyBeam)
        f_slen = 1.0;
    elseif bf/(2*tf) > 0.38*sqrt(Es/FyBeam) || h_tw > 3.76*sqrt(Es/FyBeam)
        f_slen = 0.5;
    else      
        f_slen_a = interp1([0.3*sqrt(Es/FyBeam), 0.38*sqrt(Es/FyBeam)],[1.0, 0.5], bf/(2*tf));
        f_slen_b = interp1([1.45*sqrt(Es/FyBeam), 3.76*sqrt(Es/FyBeam)],[1.0, 0.5], h_tw);
        f_slen = min(f_slen_a, f_slen_b);
    end
    
    f_adjust = [f_cp, f_pz, f_std, f_slen];
    
    % Basic plastic rotation capacity    
    MrOverMp = 0.20;    
    theta_y = Mp*Lbeam/(6*EIeff); % Yielding rotation    
    lambda = 0;
    if strcmp(connType, 'RBS')
        % Post-Northridge RBS
        thetaCap = max(0.05-0.0003*db, theta_y);
        thetaUlt = max(0.07-0.00030*db);
        beta = 1.0; % (1.10 in reference but using MmaxOverMp is better to use 1.0 here)        
        Mp = beta*Mp;
    elseif strcmp(connType, 'non_RBS')
        % Post-Northridge non-RBS (free-flange)
        thetaCap = max(0.067-0.0012*db, theta_y);
        thetaUlt = max(0.094-0.0016*db, theta_y); 
        beta = 1.0; % (1.20 in reference but using MmaxOverMp is better to use 1.0 here)        
        Mp = beta*Mp;
    else
        % Pre-Northridge (model as non-deterorating IMK or histeretic hinge)
        thetaCap = max(0.051-0.0013*db, 0.0001);
        thetaUlt = max(0.043-0.00060*db, thetaCap*1.2);
    end
    MmaxOverMp = (1 + 0.03*thetaCap/theta_y); % hardening slope 3% per ASCE 41
    
    % Corrected plastic rotation capacity
    thetaCap = max(thetaCap*f_cp*f_pz*f_std*f_slen, 0.001); % assumed a minimum of 0.1%
    thetaUlt = max(thetaUlt*f_cp*f_pz*f_std*f_slen, 1.1*thetaCap); % assumed lower bound to avoid convergence issues
    thetaPC = 1*(thetaUlt - thetaCap)/6; % assumed to avoid convergence issues

elseif strcmp(backbone, 'AISC342')
    
    
    
end

theta_y = Mp*Lbeam/(6*EIeff); % Yielding rotation


figure
fontSize = 12;
x = [0, theta_y, theta_y+thetaCap, theta_y+thetaCap, theta_y+thetaUlt, theta_y+thetaUlt];
y = [0, Mp, Mp*MmaxOverMp, MrOverMp*Mp, MrOverMp*Mp, 0];
plot(x, y, 'linewidth', 3)
xlabel('Rotation [rad]')
ylabel('Moment [kip-in]')
xlim([0, 0.16])
PlotGrayScaleForPaper(-999,'vertical','',[0.5 1],'normal',fontSize)

end