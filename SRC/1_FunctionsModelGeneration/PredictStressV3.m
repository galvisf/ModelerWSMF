% Function to compute column splice mean fracture stress.
%
% by Stillmaker
function StressAbove = PredictStressV3(model,a,tfa,tfb,KIC)
%% User Inputs
% model = Enter predictive crack model type. For Pooled Splices, Enter 'P'. For Center
% Crack, Enter 'C'. For Side Edge Crack, Enter 'E'.
%a = Crack Length. DO NOT USE HALF CRACK LENGTH FOR CC.
%tfa = Enter thickness of flange above splice.
%tfb = Enter thickness of flange below splice.
%KIC = Enter the critical mode I stress intensity factor.
%% Uncomment inputs below for use as script rather than function
% a = .355;
% tfa = 2.09;
% tfb = 2.72;
% KIC = 54;
% model = 'E';
%% Compute Equation variables
eta = a./tfb;
xi = tfa/tfb; %Flange Ratio, tfa/tfb
FlRaM1 = xi - 1; %Flange Ratio minus 1
%% Set Coefficients
if model == 'P'
    A1 = 2.51;
    A2 = 0.113;
    A3 = 1.06;
    B1 = 8.35;
    B2 = 0.750;
    C1 = 0.00000158;
    C2 = -0.000420;
    C3 = 0.0120;
    C4 = -0.000000840;
    C5 = 0.000252;
    C6 = -0.00609;
    D1 = 0.000173;
    D2 = -0.0465;
    D3 = 2.62;
    %Assume Center Crack if using Pooled model with tfa > 2.25"
    if tfa > 2.25
        alpha = 1;
        %warning('Result only accurate for Center Crack Geometry.');
    else
        alpha = 2;
        %warning('Result only accurate for Edge Crack Geometry.');
    end
elseif model == 'E'
    A1 = 4.31;
    A2 = 0.247;
    A3 = 1.12;
    B1 = 4.25;
    B2 = 0.390;
    C1 = 0.00000178;
    C2 = -0.000499;
    C3 = 0.0177;
    C4 = -0.000000917;
    C5 = 0.000272;
    C6 = -0.00659;
    D1 = 0.000300;
    D2 = -0.0766;
    D3 = 3.46;
    alpha = 2;
elseif model == 'C'
    A1 = 0.694;
    A2 = -0.0143;
    A3 = 1;
    B1 = 1.28;
    B2 = -0.646;
    C1 = 0.00000138;
    C2 = -0.000341;
    C3 = 0.00629;
    C4 = -0.000000763;
    C5 = 0.000232;
    C6 = -0.00558;
    D1 = .0000468;
    D2 = 0.0163;
    D3 = -0.172;
    alpha = 1;
else
    error('Predictive Model must be selected: Use ''P'', ''C'', or ''E''');
end
%% Compute Stresses
f1 = A1.*eta.^2 + A2.*eta + A3;
f2 = B1.*FlRaM1.^2 + B2.*FlRaM1 + 1;
f3 = C1.*eta.*KIC.^3+C2.*eta.*KIC.^2+C3.*eta.*KIC+C4.*KIC.^3+C5.*KIC.^2+C6.*KIC+1;
f4 = D1.*KIC.^2.*FlRaM1.^2 + D2.*KIC.*FlRaM1.^2 + D3.*FlRaM1.^2 + 1;
StressBelow = KIC./sqrt(pi.*eta./2./xi.*tfa)./sqrt(alpha)./f1./f2./f3./f4;
StressAbove = StressBelow./xi;
end