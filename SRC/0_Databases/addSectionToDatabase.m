function addSectionToDatabase(sectionName)
% Add sections to AISC database

% Type                 = string
% EDI_Std_Nomenclature = string
% AISC_Manual_Label    = string
% T_F   boolean for special notes (F or T)
% W     Nominal weight, lb/ft (kg/m)									
% A     Cross-sectional area, in.2 (mm2)									
% d     Overall depth of member, or width of shorter leg for angles, or width of the outstanding legs of long legs back-to-back double angles, or the width of the back-to-back legs of short legs back-to-back double angles, in. (mm)																		
% ddet	Detailing value of member depth, in. (mm)									
% Ht	Overall depth of square or rectangular HSS, in. (mm)									
% h     Depth of the flat wall of square or rectangular HSS, in. (mm)									
% OD	Outside diameter of round HSS or pipe, in. (mm)									
% bf	Flange width, in. (mm)									
% bfdet	Detailing value of flange width, in. (mm)									
% B     Overall width of square or rectangular HSS, in. (mm)									
% b     Width of the flat wall of square or rectangular HSS, or width of the longer leg for angles, or width of the back-to-back legs of long legs back-to-back double angles, or width of the outstanding legs of short legs back-to-back double angles, in. (mm)																		
% ID	Inside diameter of round HSS or pipe, in. (mm)									
% tw	Web thickness, in. (mm)									
% twdet	Detailing value of web thickness, in. (mm)									
% twdet/2	Detailing value of tw/2, in. (mm)									
% tf	Flange thickness, in. (mm)									
% tfdet	Detailing value of flange thickness, in. (mm)									
% t     Thickness of angle leg, in. (mm)									
% tnom	HSS and pipe nominal wall thickness, in. (mm)									
% tdes	HSS and pipe design wall thickness, in. (mm)									
% kdes	Design distance from outer face of flange to web toe of fillet, in. (mm)									
% kdet	Detailing distance from outer face of flange to web toe of fillet, in. (mm)									
% k1	Detailing distance from center of web to flange toe of fillet, in. (mm)									
% x     Horizontal distance from designated member edge, as defined in the AISC Steel Construction Manual, to member centroidal axis, in. (mm)																		
% y     Vertical distance from designated member edge, as defined in the AISC Steel Construction Manual, to member centroidal axis, in. (mm)																		
% eo	Horizontal distance from designated member edge, as defined in the AISC Steel Construction Manual, to member shear center, in. (mm)																		
% xp	Horizontal distance from designated member edge, as defined in the AISC Steel Construction Manual, to member plastic neutral axis, in. (mm)																		
% yp	Vertical distance from designated member edge, as defined in the AISC Steel Construction Manual, to member plastic neutral axis, in. (mm)																		
% bf/2tf	Slenderness ratio									
% b/t	Slenderness ratio for angles									
% b/tdes	Slenderness ratio for square or rectangular HSS									
% h/tw	Slenderness ratio									
% h/tdes	Slenderness ratio for square or rectangular HSS									
% D/t	Slenderness ratio for round HSS and pipe, or tee shapes									
% Ix	Moment of inertia about the x-axis, in.4 (mm4 /106)									
% Zx	Plastic section modulus about the x-axis, in.3 (mm3 /103)									
% Sx	Elastic section modulus about the x-axis, in.3 (mm3 /103)									
% rx	Radius of gyration about the x-axis, in. (mm)									
% Iy	Moment of inertia about the y-axis, in.4 (mm4 /106)									
% Zy	Plastic section modulus about the y-axis, in.3 (mm3 /103)									
% Sy	Elastic section modulus about the y-axis, in.3 (mm3 /103)									
% ry	Radius of gyration about the y-axis (with no separation for double angles back-to-back), in. (mm)									
% Iz	Moment of inertia about the z-axis, in.4 (mm4 /106)									
% rz	Radius of gyration about the z-axis, in. (mm)									
% Sz	Elastic section modulus about the z-axis, in.3 (mm3 /103)									
% J     Torsional moment of inertia, in.4 (mm4 /103)									
% Cw	Warping constant, in.6 (mm6 /109)									
% C	HSS torsional constant, in.3 (mm3 /103)									
% Wno	Normalized warping function, as used in Design Guide 9, in.2 (mm2)									
% Sw1	Warping statical moment at point 1 on cross section, as used in AISC Design Guide 9 and shown in Figures 1 and 2, in.4 (mm4 /106)																			
% Sw2	Warping statical moment at point 2 on cross section, as used in AISC Design Guide 9 and shown in Figure 2, in.4 (mm4 /106)																			
% Sw3	Warping statical moment at point 3 on cross section, as used in AISC Design Guide 9 and shown in Figure 2, in.4 (mm4 /106)																			
% Qf	Statical moment for a point in the flange directly above the vertical edge of the web, as used in AISC Design Guide 9, in.3 (mm3 /103)																	
% Qw	Statical moment for a point at mid-depth of the cross section, as used in AISC Design Guide 9, in.3 (mm3 /103)									
% ro	Polar radius of gyration about the shear center, in. (mm)									
% H     Flexural constant									
% tan(?)	Tangent of the angle between the y-y and z-z axes for single angles, where a is shown in Figure 3									
% Iw	Moment of inertia about the w-axis for single angles, in.4 (mm4 /106)									
% zA	Distance from point A to center of gravity along z-axis, as shown in Figure 3, in. (mm)									
% zB	Distance from point B to center of gravity along z-axis, as shown in Figure 3, in. (mm)									
% zC	Distance from point C to center of gravity along z-axis, as shown in Figure 3, in. (mm)									
% wA	Distance from point A to center of gravity along w-axis, as shown in Figure 3, in. (mm)									
% wB	Distance from point B to center of gravity along w-axis, as shown in Figure 3, in. (mm)									
% wC	Distance from point C to center of gravity along w-axis, as shown in Figure 3, in. (mm)									
% SwA	Elastic section modulus about the w-axis at point A on cross section, as shown in Figure 3, in.3 (mm3 /103)									
% SwB	Elastic section modulus about the w-axis at point B on cross section, as shown in Figure 3, in.3 (mm3 /103)									
% SwC	Elastic section modulus about the w-axis at point C on cross section, as shown in Figure 3, in.3 (mm3 /103)									
% SzA	Elastic section modulus about the z-axis at point A on cross section, as shown in Figure 3, in.3 (mm3 /103)									
% SzB	Elastic section modulus about the z-axis at point B on cross section, as shown in Figure 3, in.3 (mm3 /103)									
% SzC	Elastic section modulus about the z-axis at point C on cross section, as shown in Figure 3, in.3 (mm3 /103)									
% rts	Effective radius of gyration, in. (mm)									
% ho	Distance between the flange centroids, in. (mm)									
% PA	Shape perimeter minus one flange surface (or short leg surface for a single angle), as used in Design Guide 19, in. (mm)								
% PB	Shape perimeter, as used in AISC Design Guide 19, in. (mm)									

clear;

load('AISC_v14p1.mat')

ok = false; 
while ~ok

    Type                 = input('Enter section type: ','s');
    EDI_Std_Nomenclature = input('Enter section name: ','s');
    AISC_Manual_Label    = EDI_Std_Nomenclature;
    T_F    = 'F';
    disp('===================================');
    disp('Section Properties');
    disp('===================================');
    W      = input('Enter section weight (lbs/ft): ');
    A      = input('Enter section area (in^2): ');
    d      = input('Enter section depth (in): ');
    bf     = input('Enter width of flange (in): ');
    tf     = input('Enter thickness of flange (in): ');
    tw     = input('Enter thickness of web (in): ');
    % Strong axis
    Ix     = input('Enter Ix (in^4): ');
    Sx     = input('Enter Sx (in^3): ');
    rx     = input('Enter rx (in): ');
    % Weak axis
    Iy     = input('Enter Iy (in^4): ');
    Sy     = input('Enter Sy (in^3): ');
    ry     = input('Enter ry (in): ');
    % Calculated Props:
    bf_2tf = bf/(2*tf);
    h_tw   = (d-2*tf)/tw;
    Zx     = bf*tf*(d - tf) + 0.25*tw*(d - 2*tf)^2;
    Zy     = bf^2*tf/2 + 0.25*tw^2*(d - 2*tf);
    yn = input('Have you input all the properties correctly (y/n)? ','s');
    if lower(yn) == 'y'
        ok = true;
    else
        disp('===================================');
        disp('Re-enter Properties');
        disp('===================================');
    end
end



n = length(AISC_v14p1);

AISC_v14p1{n+1,  1} = Type;
AISC_v14p1{n+1,  2} = EDI_Std_Nomenclature;
AISC_v14p1{n+1,  3} = AISC_Manual_Label;
AISC_v14p1{n+1,  4} = T_F;
AISC_v14p1{n+1,  5} = W;
AISC_v14p1{n+1,  7} = d;
AISC_v14p1{n+1, 12} = bf;
AISC_v14p1{n+1, 20} = tf;
AISC_v14p1{n+1, 17} = tw;
AISC_v14p1{n+1,  6} = A;
AISC_v14p1{n+1, 36} = h_tw;
AISC_v14p1{n+1, 39} = Ix;
AISC_v14p1{n+1, 41} = Sx;
AISC_v14p1{n+1, 40} = Zx;
AISC_v14p1{n+1, 43} = Iy;
AISC_v14p1{n+1, 45} = Sy;
AISC_v14p1{n+1, 44} = Zy;

save('AISC_v14p1.mat','AISC_v14p1')



% for i = 1997:length(AISC_v14p1)
%     d  = AISC_v14p1{i,  7};
%     bf = AISC_v14p1{i, 12};
%     tf = AISC_v14p1{i, 20};
%     tw = AISC_v14p1{i, 17};
% 
%     Zx     = bf*tf*(d - tf) + 0.25*tw*(d - 2*tf)^2;
%     AISC_v14p1{i, 40} = Zx;
% 
%     Zy     = bf^2*tf/2 + 0.25*tw^2*(d - 2*tf);
%     AISC_v14p1{i, 44} = Zy;
% end
end
