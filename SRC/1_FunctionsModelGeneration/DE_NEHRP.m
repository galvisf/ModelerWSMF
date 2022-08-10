function [PS_t] = DE_NEHRP(Sds, Sd1, TL, T)
%% DE_NEHRP computes the Design Spectrum according to NEHRP (2009) in g

%By. Francisco Galvis & Anne Hulsey, Stanford University (October, 05, 2017)

%Input variables
% Sds: Spectral ordinate at 0.2s
% Sd1: Spectral ordinate at 1.0s
% TL: Long period limit response
% T: vector o scalar of desired periods

%Output variables
% PS_t: Spectral ordinates of design spectrum

%%

To = 0.2*Sd1/Sds;
Ts = Sd1/Sds;
n = length(T);
PS_t=zeros(n,1);

for i=1:n
    if T(i)<=To
        PS_t(i) = Sds*(0.4+0.6*T(i)/To);
    elseif T(i)<=Ts
        PS_t(i) = Sds;
    elseif T(i)<=TL
        PS_t(i) = Sd1/T(i);
    else
        PS_t(i) = Sd1*TL/(T(i)^2);
    end
end

end