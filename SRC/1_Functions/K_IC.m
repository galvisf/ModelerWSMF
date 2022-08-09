function [k_ic_median, k_ic_Q5, k_ic_Q95] = K_IC(cvn, Fy, alpha, T_service, Es)
% The mode I stress intensity factor (K_IC)
% 
% INPUTS
%   cvn       = Charpy-V-Notch thoughness tests at service temperature (70 F)
%   Fy        = Steel yielding stress [ksi]
%   T_service = Service temprature [F]
%   alpha     = 7.6 (Stillmaker et al. 2015 for an unbiased mean estimate for steel materials)
%               5.0 (Barsom and Rolfe (1999) for a concervative estimate
%   Es        = Steel elastic modulus in [ksi]      
%         
%%
imperial_to_metric = 1 / (6.8947 * sqrt(0.0254)); % ksi*in^0.5 to MPa*in^0.5

k_ic_dynamic = sqrt(alpha * cvn * Es / 1000); % [ksi*in^0.5]
k_ic_dynamic = max(k_ic_dynamic,30 / imperial_to_metric + 1e-6);  % to avoid negative values in Eq. 24 ASTM E1921

% Compute k_ic static (median)
T_shift = 215 - 1.5 * Fy;  % Equivalent temperature from dynamic k_ic to make it static
dT = T_service - T_shift;  % [F]
dT = (dT - 32) / 1.8;  % [C]
T0 = dT - log((imperial_to_metric * k_ic_dynamic - 30) / 70) / 0.019;  % [C] Eq. 24 ASTM E1921
T_service = (T_service - 32) / 1.8;  % [C]

k_ic_median = 30 + 70 * exp(0.019 * (T_service - T0));  % [MPa*in^0.5]
k_ic_median = k_ic_median / imperial_to_metric;  % [ksi*in^0.5]

% Compute k_ic static (Confidence bounds - Weibull distribution)
k_ic_Q5 = 20 + log((1 / (1 - 0.05))) ^ (0.25) * (11 + 77 * exp(0.019 * (T_service - T0)));
k_ic_Q5 = k_ic_Q5 / imperial_to_metric;  % [ksi*in^0.5] 5% quantile Eq. 28 ASTM E1921
k_ic_Q95 = 20 + log((1 / (1 - 0.95))) ^ (0.25) * (11 + 77 * exp(0.019 * (T_service - T0)));
k_ic_Q95 = k_ic_Q95 / imperial_to_metric;  % [ksi*in^0.5] 5% quantile Eq. 28 ASTM E1921

end