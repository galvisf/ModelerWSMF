function V_PZ_Vp = panelZoneRatio(nBeams, pzStrengthToCompare, ...
    pzFormula, Fyc, Fyb, dc, bcf, tcf, tPZ, db, Zz, Sz, Lc, Lb)
% panelZoneRatio computes the demand-to-capacity ratio of the panel zone
% dividing the projected demand equivalent to plastification of the beams
% framing in the panel zone by the capacity of the panel zone
%
% INPUTS
%   nBeams              = 1 -> one beam framing to the panel zone
%                         2 -> two beams framing to the panel zone
%   pzStrengthToCompare = 'ultimate' -> considers plastification of column flanges
%                         'yielding' -> only yielding of the column web
%   pzFormula           = 'FEMA355D' -> general equation per FEMA355D
%                         'Equilibrium' -> equilbrium on subassemblies
%   Fyc                 = Column yielding stress
%   Fyb                 = Beam yielding stress
%   dc                  = column depth
%   bcf                 = column flange width
%   tcf                 = column flange thickness
%   tPZ                 = panel zone total thickness (including doubler
%                         plates)
%   db                  = beam depth
%   Zz                  = beam plastic section modulus
%   Sz                  = beam elastic section modulus
%   Lc                  = average column length framing to the panel zone
%   Lb                  = average beam length framing to the panel zone


%%
% Yielding strength of the panel zone
if strcmp(pzStrengthToCompare, 'ultimate')
    Rn = 0.6*Fyc*(dc*tPZ)*(1 + 3*bcf*tcf^3/(propsBeam.db*dc*tw));
else
    Rn = 0.6*Fyc*(dc*tPZ); % FEMA 355D argues this is more appropiate 
                           % comparing with V_PZ using My of the beam
end

% Beam strength
Mp = Fyb*Zz;
My = Fyb*Sz;

if strcmp(pzStrengthToCompare, 'ultimate')
    % Compare strength at full plastification yielding
    if strcmp(pzFormula, 'FEMA355D')
        Ru = nBeams*Mp/db*(2*Lb/(2*Lb-dc))*((Lc-db)/Lc); % general equation per FEMA355D
    else                
        Ru = nBeams*Mp/(db - tf)*(1 - (db - tf)/(Lc - db)); % per equilbrium on subassemblies  
    end
else
    % Compare strength at first yielding
    if strcmp(pzFormula, 'FEMA355D')                
        Ru = nBeams*My/db*(2*Lb/(2*Lb-dc))*((Lc-db)/Lc); % general equation per FEMA355D
    else        
        Ru = nBeams*My/(db - tf)*(1 - (db - tf)/(Lc - db)); % per equilbrium on subassemblies 
    end
end
% Panel zone strength ratio (demand/capacity)
V_PZ_Vp = round(Ru/Rn, 3);
        

end

        