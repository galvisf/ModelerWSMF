function [gamma_y, Ke] =  panel_zone_model2021(dc, bcf, tcf, tcw, tdp, db, Fy, Es)
    % Computes the modeling parameters of a panel zone given its geometry per:
    %   Skiadopoulos, Elkadi and Lignos (2021) Proposed Panel Zone Model for Seismic Design of Steel Moment-Resisting Frames
    %   Journal of Structural Engineering ASCE, 147(4)
    %
    % INPUTS
    %    dc  = column depth
    %    bcf = column flange width
    %    tcf = column flange thichness
    %    tcw = column web thickness
    %    tdp = doubler plate thickness
    %    db  = beam depth
    %    Fy  = column steel yielding stress
    %    Es  = column steel elastic modulus
    %
    % OUTPUTS
    %    gamma_y = panel zone shear strain at first yield
    %

    % Steel shear modulus
    Gs = Es / (2 * (1 + 0.2));

    % Panel zone elastic stiffness
    tpz = tcw + tdp;  % total panel zone thickness
    % Ic = Ic + 1/12*tdb*(dc - 2*tcf - 0.5)^3 % second moment of area of the column including doubler plate
    Ic = 1 / 12 * tcw * (dc - tcf) ^ 3 + 2 * ( ...
                1 / 12 * bcf * tcf ^ 3 + (tcf * bcf) * (dc / 2 - tcf / 2) ^ 2) + 1 / 12 * tdp * ( ...
                     dc - 2 * tcf - 0.5) ^ 3;  % second moment of area of the column including doubler plate
    Ks = tpz * (dc - tcf) * Gs;  % shear stiffness
    Kb = (12 * Es * Ic / db ^ 3) * db;  % bening stiffness
    Ke = Ks * Kb / (Ks + Kb);  % Equivalent stiffness

    % Column flanges stiffness
    Ksf = 2 * (tcf * bcf * Gs);
    Kbf = 2 * (12 * Es * (bcf * tcf ^ 3 / 12) / db ^ 3) * db;
    Kf = Ksf * Kbf / (Ksf + Kbf);

    % Panel zone yielding strength
    Vy = ((0.58 * Kf / Ke + 0.88) / (1 - Kf / Ke)) * (Fy / sqrt(3)) * (dc - tcf) * tpz;

    % Panel zone yielding strain
    gamma_y = Vy / Ke;
end