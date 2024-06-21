% computeStrengthSteelSection based on the AISC 360 specification for
% wide-flange and box section in strong and weak orientations
% 
% INPUTS
%   Es          = [ksi]
%   Fy          = [ksi]
%   props       = [in]
%               for wide-flange sections
%               Iy [in^4]
%               A [in^2]
%               J [in^4]
%               Cw [in^6]
%               db [in]
%               bf [in]
%               tw [in]
%               tf [in]
%               Sz [in^3]
%               Zz [in^3]
%               Sy [in^3]
%               Zy [in^3]
%
%               for box sections
%               db [in]
%               bf [in]
%               tw [in]
%               tf [in]
%               Sz [in^3]
%               Zz [in^3]
%               Sy [in^3]
%               Zy [in^3]
%               
%   Lb          = unbraced length [in]
%   c           = 1; % factor for torsional stiffness (W sections use == 1)
%   Cb          = 1; % factor for moment redistribution (simply supported beam == 1)
%   orientation = 1 -> strong orientation
%                 0 -> weak orientation
%   isBox       = true/false
%
% OUTPUTS
%   Mn          = [kip-ft]
%   Vn          = [kip]
%
function [Mn, Vn] = computeMnVnSteelProfile(Es,Fy,props,Lb,c,Cb,orientation,isBox)
    
    if isBox
        % Read section properties
        db = props.db;
        bf = props.bf;
        tw = props.tw;
        tf = props.tf;
        Sz = props.Sz;
        Zz = props.Zz;
        Sy = props.Sy;
        Zy = props.Zy;        
        
        if orientation == 1
            %%%%%%%%%% Strong orientation %%%%%%%%%%
            % Shear capacity
            Vn = 0.6*Fy*db*(tw*2);

            % Flexural capacity (AISC 360 Section F7)
            % (Plastification)
            Mp = Fy*Zz;
        
            % (Flange Local buckling)
            if (bf - 2*tw)/tf < 1.12*sqrt(Es/Fy)
                % compact section so no need to check local buckling
                MnFLB = Mp;
            elseif (bf - 2*tw)/tf < 1.40*sqrt(Es/Fy)
                % no-compact section
%                 disp('no compact flange box section')
                MnFLB = min(Mp, Mp - (Mp - Fy*Sz)*(3.57*bf/tf*sqrt(Fy/Es) - 4));
            else
                % Slender section
%                 disp('slender flange box section')
                be = min(bf, 1.92*tf*sqrt(Es/Fy)*(1 - 0.38/(bf/tf))*sqrt(Es/Fy)); % effective width for box section
                Se = 1/12*(2*db^3*tw + 2*tf^3*(be-2*tw)) + 2*tf*(be-2*tw)*(db/2 - tf/2)^2;
                MnFLB = Fy*Se;
            end

            % (Web Local buckling)
            if (db - 2*tf)/tw < 1.12*sqrt(Es/Fy)
                % compact section so no need to check local buckling
                MnWLB = Mp;
            else
                % no-compact section
%                 disp('no compact web box section')
                h = db - tf;
                MnWLB = min(Mp, Mp - (Mp - Fy*Sz)*(0.305*h/tw*sqrt(Fy/Es) - 0.738));
            end
            
            Mn = min([MnFLB, MnWLB, Mp]) / 12; % [kip-ft]
            
        else
            %%%%%%%%%% Weak orientation %%%%%%%%%%
            % Shear capacity
            Vn = 0.6*Fy*bf*(tf*2);
            
            % Flexural capacity (AISC 360 Section F)
            % (Plastification)
            Mp = Fy*Zy;
            
            % (Web Local buckling)
            if (bf - 2*tw)/tf < 1.12*sqrt(Es/Fy)
                % compact section so no need to check local buckling
                MnWLB = Mp;
            elseif (bf - 2*tw)/tf < 1.40*sqrt(Es/Fy)
                % no-compact section
%                 disp('no compact flange box section ')
                MnWLB = min(Mp, Mp - (Mp - Fy*Sz)*(3.57*(bf - 2*tw)/tf*sqrt(Fy/Es) - 4));
            else
                % Slender section
%                 disp('slender flange box section')
                be = min(bf, 1.92*tf*sqrt(Es/Fy)*(1 - 0.38/((bf - 2*tw)/tf))*sqrt(Es/Fy)); % effective width for box section
                Se = 1/12*(2*db^3*tw + 2*tf^3*(be-2*tw)) + 2*tf*(be-2*tw)*(db/2 - tf/2)^2;
                MnWLB = Fy*Se;
            end

            % (Flange Local buckling)
            if (db - 2*tf)/tw < 1.12*sqrt(Es/Fy)
                % compact section so no need to check local buckling
                MnFLB = Mp;
            elseif (db - 2*tf)/tw < 1.4*sqrt(Es/Fy)
                % no-compact section
%                 disp('no compact flange box section (weak orientation)')
                MnFLB = min(Mp, Mp - (Mp - Fy*Sy)*(3.57*(db - 2*tf)/tw*sqrt(Fy/Es) - 4));
            else
                % slender section
%                 disp('slender flange box section (weak orientation)')
                be = min(db, 1.92*tf*sqrt(Es/Fy)*(1 - 0.38/((db - 2*tf)/tw))*sqrt(Es/Fy)); % effective width for box section
                Se = 1/12*(2*be*tw^3 + 2*tf*(bf-2*tw)^3) + 2*tw*be*(bf/2 - tw/2)^2;
                MnFLB = Fy*Se;
            end
            
            Mn = min([MnFLB, MnWLB, Mp]) / 12; % [kip-ft]
        end
    else
        % Read section properties
        Iy = props.Iy;
        ry = sqrt(props.Iy/props.A);
        J  = props.J;
        Cw = props.Cw;
        Sz = props.Sz;
        Zz = props.Zz;    
        db = props.db;
        tw = props.tw;
        tf = props.tf;
        ho = db - tf; % distance between flange centroids
        bf = props.bf;
        Zy = props.Zy;
        Sy = props.Sy;
             
        if orientation == 1
            %%%%%%%%%% Strong orientation %%%%%%%%%%
            % Shear capacity
            Vn = 0.6*Fy*db*tw;

            % Flexural capacity (AISC 360 Section F)
            % (Plastification)
            Mp = Fy*Zz;
            
            % (Lateral torsional buckling)
            rts = sqrt(sqrt(Iy*Cw)/Sz);
            Lp = 1.76*ry*sqrt(Es/Fy); % largest unbraced length for developing Mp [in]
            Lr = 1.95*rts*Es/(0.7*Fy)*sqrt(J*c/(Sz*ho) + sqrt((J*c/(Sz*ho))^2 + 6.76*(0.7*Fy/Es)^2)); % unbraced length limit to have bad lateral-torsional buckling [in]
            
            if Lb < Lp
                MnLTB = Mp;
            elseif Lb < Lr
%                 disp('Inelastic LTB')
                MnLTB = min(Cb*(Mp - (Mp - 0.7*Fy*Sz)*(Lb - Lp)/(Lr - Lp)), Mp);                
            else
%                 disp('Elastic LTB')
                MnLTB = min(Cb*(pi^2*Es*Sz/(Lb/rts)^2*sqrt(1 + 0.078*J*c/(Sz*ho)*(Lb/rts)^2)), Mp);                
                
            end               

            % (Local buckling)
            if ((bf - tw)/2)/tf < 0.38*sqrt(Es/Fy)
                % compact section so no need to check local buckling
                MnLB = Mp;
            elseif ((bf - tw)/2)/tf < sqrt(Es/Fy)
                % no-compact section
%                 disp('no compact I section')
                lambda = bf/(2*tf);
                lambdapf = 0.38*sqrt(Es/Fy);
                lambdar = sqrt(Es/Fy);
                
                MnLB = Zz*Fy - (Zz*Fy - 0.7*Sz*Fy)*...
                    (lambda - lambdapf)/(lambdar - lambdapf);
            else
                % Slender section
%                 disp('slender I section')
                lambda = bf/(2*tf);
                h = db - 2*tf;
                kc = 4/sqrt(h/tw);
                MnLB = 0.*Es*kc*Sz/lambda^2;
            end
            
            Mn = min([MnLTB, MnLB, Mp]) / 12; % [kip-ft]
            
        else
            %%%%%%%%%% Weak orientation %%%%%%%%%%
            % Shear capacity
            Vn = 0.6*Fy*bf*(tf*2);
            
            % (Plastification)
            Mp = min(Zy*Fy, 1.6*Fy*Sy);
            
            % (Local buckling)
            if ((bf - tw)/2)/tf < 0.38*sqrt(Es/Fy)
                % compact section so no need to check local buckling
                MnLB = Mp;
            elseif ((bf - tw)/2)/tf < sqrt(Es/Fy)
                % no-compact section
%                 disp('no compact I section (weak orientation)')
                lambda = bf/tf;
                lambdapf = 0.38*sqrt(Es/Fy);
                lambdar = sqrt(Es/Fy);
                
                MnLB = Mp - (Mp - 0.7*Sy*Fy)*...
                    (lambda - lambdapf)/(lambdar - lambdapf); 
            else
                % Slender section
%                 disp(['slender I section (weak orientation)'])
                Fcr = 0.69*Es/(bf/tf)^2;
                MnLB = Fcr*Fy;
            end
            
            Mn = min([MnLB, Mp]) / 12; % [kip-ft]
        end
    end     
%     disp(['Mn/Mp=', num2str(Mn*12/Mp)])
end
