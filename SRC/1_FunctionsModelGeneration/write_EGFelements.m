%% This function writes the EGF elements
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function AllEle = write_EGFelements(INP,AllEle,bldgData,AISC_v14p1,addEGF,...
                    Es,FyCol,backbone,degradation)
%% Read relevant variables
storyNum    = bldgData.storyNum;
bayNum      = bldgData.bayNum;
axisNum     = bldgData.axisNum;
frameType   = bldgData.frameType;
nGB         = bldgData.nGB;
colSizeEGF  = bldgData.colSizeEGF;
beamSizeEGF = bldgData.beamSizeEGF;
orientation = bldgData.orientation;
storyHgt    = bldgData.storyHgt;

% Assume for simplicity that the stiffness of the columns in the orthogonal 
% MRF have the same properties than the gravity columns
nGC         = bldgData.nGC + bldgData.nColMRForthogonal;


AllEle.EGFcol  = [];
AllEle.EGFbeam = [];

if strcmp(frameType, 'Perimeter')
    %%
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'#                                          EGF COLUMNS AND BEAMS                                   #\n');
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'\n');
    
    isBox = false;
    if addEGF
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Build EGF elements %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(INP,'# GRAVITY COLUMNS\n');
        for Story=1:storyNum
            Fi=Story; Fj=Story+1;
            
            % Get column section properties
            props = getSteelSectionProps(colSizeEGF{Story}, AISC_v14p1);
            if strcmp(colSizeEGF, 'BOX')
                isBox = true;
            end
            
            % Column length
            Lcol = storyHgt(Story);
            
            % Axial load
            Pg = 0; % ignore gravity load effects on the column plastic hinge
            
            if strcmp(backbone, 'Elastic')
                Pye = props.A*FyCol;
                if Pg/Pye <= 0.5
                    t_b = 1.0;
                else
                    t_b = 4*Pg/Pye*(1 - Pg/Pye);
                end
                if orientation == 1
                    Aw = props.tw*props.db;
                    I = props.Iz;       
                else
                    Aw = props.tf*props.bf*2;
                    I = props.Iy; 
                end
                G = Es/(2*(1+0.3));
                L = Lcol/2;              % Shear spam (half the length)
                Ks = G*Aw/L;             % Shear lateral stiffness of the column
                Kb = 12*Es*I*t_b/Lcol^3;    % bending lateral stiffness of the column
                Ke = Ks*Kb/(Ks+Kb);      % effective lateral stiffness
                EIeff = Ke*Lcol^3/12;    % effective EI to use in element without shear deformation in its formulation
                Ieff = EIeff/Es;         % effective I to use in element without shear deformation in its formulation
                                
                fprintf(INP,'set A   %.3f\n', props.A);
                fprintf(INP,'set Ieff   %.3f\n', Ieff);                                
                % Write left column
                iNode=10000*Fi+100*(axisNum+1);
                jNode=10000*Fj+100*(axisNum+1);
                ElemID=600000+1000*Story+100*(axisNum+1);
                fprintf(INP,'element elasticBeamColumn   %d %d %d $A $Es $Ieff $trans_selected\n',...
                    ElemID, iNode, jNode);
                AllEle.EGFcol = [AllEle.EGFcol; ElemID, iNode, jNode];
                % Write right column
                iNode=10000*Fi+100*(axisNum+2);
                jNode=10000*Fj+100*(axisNum+2);
                ElemID=600000+1000*Story+100*(axisNum+2);
                fprintf(INP,'element elasticBeamColumn   %d %d %d $A $Es $Ieff $trans_selected\n',...
                    ElemID, iNode, jNode);
                AllEle.EGFcol = [AllEle.EGFcol; ElemID, iNode, jNode];
                
            else
                % Hinge properties
                [Ieff, Mp, McMp, MrMp, theta_p, theta_pc, theta_u, lambda, ~] = ...
                    steelColumnHinge(isBox, backbone, degradation, orientation, ...
                    props, Lcol, FyCol, Es, Pg);
                A_GC = nGC(Story) *  props.A/2; % divide by 2 since the model has 2 columns
                Ieff_GC = nGC(Story) *  Ieff/2;
                Zp_GC = nGC(Story) / 2 * Mp/FyCol; % this captures the strain hardening factor added in the steelBeamHinge function

                % Write column section data
                fprintf(INP, 'set secInfo {%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f};\n', ...
                    Zp_GC, McMp, MrMp, theta_p, theta_pc, theta_u, lambda);

                % Write left column
                iNode=10000*Fi+100*(axisNum+1);
                jNode=10000*Fj+100*(axisNum+1);
                ElemID=600000+1000*Story+100*(axisNum+1);
                fprintf(INP, 'hingeBeamColumn %d %d %d "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag %.3f %.3f $degradation $c $secInfo $secInfo 0 0;\n', ...
                    ElemID, iNode, jNode, A_GC, Ieff_GC);
                AllEle.EGFcol = [AllEle.EGFcol; ElemID, iNode, jNode];

                % Write right column
                iNode=10000*Fi+100*(axisNum+2);
                jNode=10000*Fj+100*(axisNum+2);
                ElemID=600000+1000*Story+100*(axisNum+2);
                fprintf(INP, 'hingeBeamColumn %d %d %d "Vertical" $trans_PDelta $n $Es $FyCol $rigMatTag %.3f %.3f $degradation $c $secInfo $secInfo 0 0;\n', ...
                    ElemID, iNode, jNode, A_GC, Ieff_GC);
                AllEle.EGFcol = [AllEle.EGFcol; ElemID, iNode, jNode];
            end
        end
        fprintf(INP,'\n');
        
        fprintf(INP,'# GRAVITY BEAMS\n');
        for Floor=2:storyNum+1
            
            Section=beamSizeEGF{Floor-1};
            props = getSteelSectionProps(Section, AISC_v14p1);
            A_GB = nGB(Story) *  props.A;
            I_GB = nGB(Story) *  props.Iz;
            
            nodeID1=10000*Floor+100*(axisNum+1)+04;
            nodeID2=10000*Floor+100*(axisNum+2)+02;
            ElemID=500000+1000*Floor+100*(bayNum+1)+00;
            fprintf(INP,'element elasticBeamColumn %7d %7d %7d %.4f $Es [expr $Comp_I_GC * %.4f] $trans_selected;\n', ElemID, nodeID1, nodeID2, A_GB, I_GB);
            AllEle.EGFbeam = [AllEle.EGFbeam; ElemID, nodeID1-4, nodeID2-2];
        end
        fprintf(INP,'\n');
    else
        %%%%%%%%%%%%%%%%%%%%%%%% Build leaning elements %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % leaning column label: 2+story+(pierNum+1)+00
        
        fprintf(INP, '# LEANING COLUMN\n');
        
        AllEle.leaningCol = [];
        
        for Story = 1:storyNum
            
            ElemID = 2e6+Story*10000+(axisNum+1)*100;
            iNode = Story*10000+(axisNum+1)*100+02;
            jNode = Story*10000+(axisNum+1)*100+04;
            
            % element elasticBeamColumn  eleID  NID  NID A E I $PDeltaTransf;
            fprintf(INP, 'element elasticBeamColumn %d %d %d $A_Stiff $Es $I_Stiff $trans_selected;\n', ...
                ElemID, iNode, jNode);
            
            AllEle.EGFcol = [AllEle.EGFcol; ElemID, iNode-2, jNode-4+10000];
            
        end
    end
end

end

