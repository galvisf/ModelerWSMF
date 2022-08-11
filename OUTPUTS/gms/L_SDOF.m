function [U, V, A, T, PSa, Sv, Sd] = L_SDOF(dT, Xo, Te, D)
% SDOF_Response computes the time history response of a SDOF oscilator with
% period Te and damping D, under the ground motion Xo with time step dT 
% using the Newmark Beta Method (1959).

%By. Francisco Galvis

%Input variables:
% dT: time interval from original ground motion record
% Xo: Column vector of acceleration values from original ground motion record in [g]
% Te: SDOF system period
% D: SDOF system damping (in fraction, NOT in %)

%Output variables
% PSa: Pseudo-spectral acceleration of the SDOF oscilator in [g]
% TAP: Time at peak response of the oscilator
% sign: Sign of the peak response of the oscilator
% U: Vector of displacement response
% T: Vector of time intervals

%Convergance variables
B=1/6; % Beta value(0<Beta<0.5)\n Escalonado = 1/8\n Lineal= 1/6\n Constante=1/4
ap=20; %Minimum number of analysis per structural period

m=1; % Mass
w=((2*pi())/Te)*sqrt(1-D^2); % Damped natural frequency
k=m/(Te/(2*pi))^2; % Stiffness
c=2*m*D*w;  % Damping constant

%% For Te = 0: Structure moves exactly as the ground

g = 9.8066; %m/s2

if Te == 0
    n = length(Xo);
    te = dT*(length(Xo)-1); % Total record time
    T = 0:dT:te; % New time vector
    U = zeros(n,1);%Relative displacement vector of oscilation response
    V = zeros(n,1);%Relative velocity vector of oscilation response
    A = Xo;
    Sd = 0;
    Sv = 0;
    
    TAP = 0; % There is not peak RELATIVE displacement
    sign = 0; % There is not peak RELATIVE displacement

    Sa = max(abs(A));
    PSa = Sa;
    return
end

%% GROUND MOTION RE-SAMPLING
%When delta t of the record is greater than T/20 it is necesary to
%re-sample the record with linear interpolation so it has at least 20
%samples per period for the numerical solution

g = 9.8066; %m/s2
Xo = Xo*g; % units to m/s2 
Xo = [0;Xo(1:end)]; % Adds the first value of the record as 0
te = dT*(length(Xo)-1); % Total record time

dt = min(Te/ap,dT); % min(Te/ap,dT); Minimum delta t of the record so there are a minimum 
                    %of "ap" solutions within the structural period

T = 0:dt:te; % New time vector
t = 0:dT:te; % Original time vector
Xo_rs = interp1(t, Xo,T)'; % New Ground Motion Acc. at step dt
clear t

n = length(Xo_rs); %Number of stations to calculate the entire record

%% Newmark Beta Method
%Definition of external excitation: P(t)=-m*Xo
P=-m*Xo_rs;
    
U = zeros(n,1);%Relative displacement vector of oscilation response
V = zeros(n,1);%Relative velocity vector of oscilation response
A = zeros(n,1);%Relative acceleration vector of oscilation response

%Initial conditions
U(1) = 0;
V(1) = 0;
A(1) = (P(1,1)-c*U(1)-k*V(1))/m;

k_tilda = k + (0.5/(B*dt))*c + (1/(B*dt^2))*m;
a = (1/(B*dt))*m+(0.5/B)*c;
b = (1/(2*B))+dt*(0.5/(2*B)-1)*c;


% Prelocate variables
Sd = U(1);
TAP = 0;
sign = 1;
dP = zeros(n-1,1);
dP_tilda = zeros(n-1,1);
dU = zeros(n-1,1);
dV = zeros(n-1,1);
dA = zeros(n-1,1);

% Newmark method
for i=1:n-1
    t=T(i+1); 
    dP(i) = P(i+1)-P(i);
    dP_tilda(i) = dP(i) + a*V(i) + b*A(i);
    dU(i) = dP_tilda(i)/k_tilda;
    dV(i) = (0.5/(B*dt))*dU(i) - (0.5/B)*V(i) + dt*(1-(0.5/(2*B)))*A(i);
    dA(i) = (1/(B*dt^2))*dU(i)-(1/(B*dt))*V(i)-(1/(2*B))*A(i);
    U(i+1) = U(i)+dU(i);
    V(i+1) = V(i)+dV(i); 
    A(i+1) = A(i)+dA(i);
    
    % Finding of Sd, Time at Peak (TAP) and the sign of this value
    if abs(U(i+1))>Sd
        Sd=abs(U(i+1));
        TAP = T(i+1);
        sign = U(i+1)/(abs(U(i+1)));
    end
    
end

%Total acceleration
A=A+Xo_rs;
% 
% Vg = cumtrapz(Xo_rs)*dt;
% Ug = cumtrapz(Vg)*dt;
% Vtotal = V + Vg;
% Utotal = U + Ug;
% Sd = max(abs(Utotal));

%% Spectral ordinates for Te and D
Sv = max(abs(V));
Sa = max(abs(A));
PSa = Sd*w^2/g;

end