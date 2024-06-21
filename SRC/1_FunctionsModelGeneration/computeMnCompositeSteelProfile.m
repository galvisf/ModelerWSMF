% computeStrengthCompositeSteelSection
% 
% INPUTS
%   Fy    = [ksi]
%   fc    = [ksi]
%   props = [in]
%   tdeck = [in]
%   tslab = [in]
%   Lv    = total girder length [ft]
%   La    = girder separation distance [ft]
%   caRatio = composite action fraction (often around 0.35)
%
% OUTPUTS
%   Mn    = [kip-ft]
%
function Mn = computeMnCompositeSteelProfile(Fy,fc,props,tdeck,tslab,Lv,La,caRatio)

    % Read section properties   
    db = props.db;
    A  = props.A;
    tf = props.tf;
    tw = props.tw;
    bf = props.bf;
    Lv = Lv * 12; % [in]
    La = La * 12; % [in]

    % Flexural capacity
    beff = min(2*Lv/8, La); % effective slab width
    Qn = caRatio*min(Fy*A, 0.85*abs(fc)*beff*(tdeck/2 + tslab)); % shear flow at the interphase concrte-steel
    a = Qn/(0.85*fc*beff); % depth of the concrete block
    
    y_EN = db/2 + Qn/(tw*Fy);
    
    if y_EN < db - tf
        Mn = 0.85*fc*beff*a * (db + tdeck + tslab - a/2 - y_EN) + ...
            (tf*bf*Fy*(y_EN - tf/2) + tf*bf*Fy*(db - tf/2 - y_EN) + ...
            tw*Fy*(y_EN - tf)^2/2 + tw*Fy*(db - y_EN - tf)^2/2)*1.05; 
        % adjustment of 1.05 to account for the rounded area ignored with this procedure
    else
        % Assume EN at the interphase
        Mn = 0.85*fc*beff*a * (tdeck + tslab - a/2) + A*Fy*db/2;
    end
    Mn = Mn / 12; % [kip-ft]
    
end
