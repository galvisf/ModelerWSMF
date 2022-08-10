% getFloorWeigths returns the weights per square foot (psf) for a WSMF type
% building assuming a generic occupancy type (office)
% 
% INPUTS
%    MEC          = true/false mechanical floor
%    concreteType = 'lightweight' or 'normalweigth'
%    claddingType = string containing: 
%                   'glass', 'aluminum', 'GFRC', 'light'
%                   'concrete'
%                   all others
%    tslab        = thickness of the slab above the steel deck [in]
%    tdeck        = thickness of the steel deck [in]
% 
% OUTPUTS
%    DL     = dead load of structure [psf]
%    SDL    = superimposed dead load[psf]
%    LL_red = live load reduced [psf]
%    LL     = total live load [psf]
%    GL     = generic permanent load [psf]
%    CL     = cladding load [psf]
%
function [DL, SDL, LL_red, LL, GL, CL] = getFloorWeigths(MEC, concreteType, claddingType, tslab, tdeck)

% Select concrete unit weigth
if strcmp(concreteType, 'Lightweight')
    gammaConc = 115; % Typical concrete unit weigth including steel
else
    gammaConc = 155; % Typical concrete unit weigth including steel
end

%%%%%%%%%%%% Dead load %%%%%%%%%%%%
floorSystem = (tslab + tdeck/2)/12*gammaConc;
if MEC
    partitions = 0;
    carpets = 0;
    ceiling = 0;
    mechDucts = 0;
    fireprof = 3;
    SteelFraming = 0; % 8
    SDL = SteelFraming + partitions + carpets + ceiling + mechDucts + fireprof;
else
    % Based on loads suggested in SAC project archetypes
    partitions = 20; % specified minimum in UBC 1961 for offices
    carpets = 3;
    ceiling = 7;
    mechDucts = 7;
    fireprof = 3;
    SteelFraming = 0; % 8
    SDL = SteelFraming + partitions + carpets + ceiling + mechDucts + fireprof;
end
DL = floorSystem;

%%%%%%%%%%%% Live load %%%%%%%%%%%%
LL = 50; % typical for office (UBC 1961, 1973)
LL_red = 0.6*LL; % typical for office reduced for simulatenous occurance

%%%%%%%%%%%% Generic load (for mechanical floors) %%%%%%%%%%%%
if MEC
    % Based on CMH (2017) thesis assumptions 
    GL = 130;
else
    GL = 0;
end

%%%%%%%%%%%% Cladding load %%%%%%%%%%%%
if contains(claddingType, 'glass') || contains(claddingType, 'aluminum') ...
    || contains(claddingType, 'GFRC') || contains(claddingType, 'light')
    CL = 15;
elseif contains(claddingType, 'concrete')
    CL = 25;
else
    CL = 35; % stone, brick, 
end

end