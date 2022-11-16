%% This function writes the code to call the procedure that builds the beams
%
% Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function AllEle = write_Beams(INP,AllEle,bldgData,AISC_v14p1,connType,backbone,...
                            generation,degradation,fractureElement,Es,...
                            FyBeam,FyCol,slabFiberMaterials)
%   %% Read relevant variables
    floorNum  = bldgData.floorNum;
    bayNum    = bldgData.bayNum;
    colSize   = bldgData.colSize;
    beamSize  = bldgData.beamSize;
    storyHgt  = bldgData.storyHgt;
    bayLgth   = bldgData.bayLgth;
    tcont     = bldgData.tcont;
    webConnection = bldgData.webConnection;
    doublerPlates = bldgData.doublerPlates;
    beamBracing   = bldgData.beamBracing;
    
    fc      = slabFiberMaterials.fc;
    La      = slabFiberMaterials.La;
    caRatio = slabFiberMaterials.caRatio;
    trib   = bldgData.trib;
    tslab   = bldgData.tslab;
    
    AllEle.beam = []; % Matrix with element data for plots    
    AllEle.MpP_Mp = zeros(floorNum, bayNum); % Matrix of ratio composite to bare section POSITIVE moment strength
    AllEle.MpN_Mp = zeros(floorNum, bayNum); % Matrix of ratio composite to bare section NEGATIVE moment strength
    AllEle.Mn_Mp_beam = zeros(floorNum, bayNum); % Matrix of ratio nominal to plastic bare section flexural strength
    
%     backbone = 'ASCE41'; %%%%%%%%%%%%%%% DELETE AFTER DEBUG %%%%%%%%%%%%%%%%
    
    %%
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'#                                             BEAM ELEMENTS                                        #\n');
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'\n');
  
    fprintf(INP,'# COMMAND SYNTAX \n');
    if strcmp(backbone, 'Elastic')
        fprintf(INP,'# element elasticBeamColumn   ElementID node_i node_j ...\n');                            
    else
        fprintf(INP,'# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda\n');
        if fractureElement
            fprintf(INP,'# (Welded web) fracSecGeometry  d, bf, tf, ttab, tabLength, dtab\n');  
            fprintf(INP,'# (Bolted web) fracSecGeometry  d, bf, tf, ttab, tabLength, str, boltDiameter, Lc\n');  
            fprintf(INP,'# hingeBeamColumnFracture  ElementID node_i node_j eleDir, ... A, Ieff, ... webConnection\n');  
        end
        fprintf(INP,'# hingeBeamColumn  ElementID node_i node_j eleDir, ... A, Ieff\n');  
    end
    
    % Compute properties and write each beam
    for Floor = 2:floorNum       
        baysDone = zeros(bayNum, 0);
        
        for Bay = 1:bayNum

            if ~isempty(beamSize{Floor-1, Bay}) && ~ismember(Bay, baysDone)
                % Axis for left column
                Axis_i = Bay;                
                
                % Find axis for right column (in case of missing columns the beam spans multiple bays)
                Axis_j = 0;
                i = 1;
                while Axis_j == 0
                    if ~isempty(colSize{Floor-1, Bay+i}) || ~isempty(colSize{min(Floor, floorNum-1), Bay+i})
                        Axis_j = Bay+i;
                    else
                        i = i + 1;
                    end
                end
                if Axis_j == Bay+1
                    fprintf(INP, '\n# Beams at floor %d bay %d\n', Floor, Bay);
                else
                    fprintf(INP, '\n# Beams at floor %d bays %d to %d\n', Floor, Bay, Axis_j-1);
                end
                baysDone(Bay:Axis_j-1) = Bay:Axis_j-1;
                
                % Element and node labels
                ElementID = 1e6 + Floor*1e4 + Bay*100;
                node_i = 4000000 + Floor*1e4 + Axis_i*100 + 4; % left of beam
                node_j = 4000000 + Floor*1e4 + Axis_j*100 + 2; % right of beam                
                
                % Save data for plot
                nodeCL_i = Floor*10000+Axis_i*100;
                nodeCL_j = Floor*10000+Axis_j*100;
                AllEle.beam = [AllEle.beam; ElementID, nodeCL_i, nodeCL_j];
                
                % beam properties
                beamProps = getSteelSectionProps(beamSize{Floor-1, Bay}, AISC_v14p1);
                A = beamProps.A;                
                d = beamProps.db;
                tw = beamProps.tw;
                bf = beamProps.bf;
                tf = beamProps.tf;
                Zz = beamProps.Zz;   
                Sz = beamProps.Sz;   

                % Left column properties
                % (Takes the column below and if does not exist takes the
                % column above) 
                section = colSize{Floor-1, Axis_i};            
                if isempty(section)
                    section = colSize{Floor, Axis_i};
                end 
                props = getSteelSectionProps(section , AISC_v14p1);
                dc_i = props.db;
                bcf_i = props.bf;
                tcf_i = props.tf;                     
                % Doubler plates
                tdp_i = doublerPlates(Floor-1, Axis_i);                    
                tPZ_i = props.tPZ_z + tdp_i; 

                % Right column properties
                % (Takes the column below and if does not exist takes the
                % column above)            
                section = colSize{Floor-1, Axis_j};            
                if isempty(section)
                    section = colSize{Floor, Axis_j};
                end 
                props = getSteelSectionProps(section , AISC_v14p1);
                dc_j = props.db;
                bcf_j = props.bf;
                tcf_j = props.tf;                   
                % Doubler plates
                tdp_j = doublerPlates(Floor-1, Axis_j);
                tPZ_j = props.tPZ_z + tdp_j; 

                % Beam clear length
                Lbeam = sum(bayLgth(Bay:Axis_j-1)) - dc_i/2 - dc_j/2;
                
                % Beam unbraced length
                if beamBracing
                    Lb = 4.5/0.025; % [in]
                else
                    Lb = Lbeam;
                end
                
                % Write beams in model file
                if strcmp(backbone, 'Elastic')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%           Elastic model           %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Effective Elastic stiffness (to account for shear deformation) - ASSUMED
                    % BEAM IS FIXED-FIXED
                    Aw = tw*d;
                    G = Es/(2*(1+0.3));
                    L = Lbeam/2;             % Shear spam (half the length)
                    Ks = G*Aw/L;             % Shear lateral stiffness of the column
                    Iz = Sz*d/2;
                    Kb = 12*Es*Iz/Lbeam^3;   % bending lateral stiffness of the column
                    Ke = Ks*Kb/(Ks+Kb);      % effective lateral stiffness
                    EIeff = Ke*Lbeam^3/12;   % effective EI to use in element without shear deformation in its formulation
                    Ieff = EIeff/Es;          % effective I to use in element without shear deformation in its formulation
                                        
                    % Write beam element
                    fprintf(INP,'set Ieff  [expr %.3f * $Comp_I]\n', Ieff);
                    fprintf(INP,'set A   %.3f\n', A);
                    fprintf(INP,'element elasticBeamColumn   %d %d %d $A $Es $Ieff $trans_selected\n',ElementID, node_i, node_j);
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%         Inelastic model           %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Left connection (setback only possible in left side)
                    if Axis_i==1 || Axis_i==bayNum+1 || isempty(beamSize{Floor-1, Axis_i-1}) ...
                       || isempty(beamSize{Floor-1, Axis_i})
                        nBeams_i = 1; % exterior panel zone
                    else
                        nBeams_i = 2; % interior panel zone
                    end

                    % Right connection (setback only possible in left side)
                    if Axis_j==1 || Axis_j==bayNum+1 || isempty(beamSize{Floor-1, Axis_j-1}) ...
                       || isempty(beamSize{Floor-1, Axis_j})
                        nBeams_j = 1; % exterior panel zone
                    else
                        nBeams_j = 2; % interior panel zone
                    end
                    
                    % Get average story height (needed for ASCE41 backbone calculations)
                    if Floor < floorNum
                        LcolAvg = mean(storyHgt(Floor-1), storyHgt(Floor));
                    else
                        LcolAvg = storyHgt(Floor-1);
                    end
                    
                    % Hinge properties
                    [Ieff, Mp_i, McMp_i, MrMp_i, theta_p_i, theta_pc_i, theta_u_i, lambda_i, ~, ~] = ...
                        steelBeamHinge(backbone, connType, degradation, beamProps, Lb, Lbeam, ...
                        FyBeam, Es, dc_i, tPZ_i, tcf_i, tcont, LcolAvg, nBeams_i, FyCol);
                    [~, Mp_j, McMp_j, MrMp_j, theta_p_j, theta_pc_j, theta_u_j, lambda_j, ~, ~] = ...
                        steelBeamHinge(backbone, connType,degradation, beamProps, Lb, Lbeam, ...
                        FyBeam, Es, dc_j, tPZ_j, tcf_j, tcont, LcolAvg, nBeams_j, FyCol);                                          
                    
                    AllEle.Mn_Mp_beam(Floor, Bay) = mean([Mp_i/(Zz*FyBeam), Mp_j/(Zz*FyBeam)]);
                    
                    % Write beam section data
                    Zp_i = Mp_i/FyBeam; % this captures the strain hardening factor added in the steelBeamHinge function
                    Zp_j = Mp_j/FyBeam; 
                    fprintf(INP, 'set secInfo_i {%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f};\n', ...
                        Zp_i, McMp_i, MrMp_i, theta_p_i, theta_pc_i, theta_u_i, lambda_i);
                    fprintf(INP, 'set secInfo_j {%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f};\n', ...
                        Zp_j, McMp_j, MrMp_j, theta_p_j, theta_pc_j, theta_u_j, lambda_j);
                    
                    % Compute composite section strength ratio (MpP/Mp)
                    MpP_i = computeMnCompositeSteelProfile(FyBeam,fc,beamProps,trib,tslab,Lbeam,La,caRatio); % kip-ft
                    MpP_j = computeMnCompositeSteelProfile(FyBeam,fc,beamProps,trib,tslab,Lbeam,La,caRatio); % kip-ft
                    MpP_Mp = max(min(mean([MpP_i*12/Mp_i, MpP_j*12/Mp_j]), 1.30), 1);
                    MpN_Mp = min(1.10, MpP_Mp);
                    AllEle.MpP_Mp(Floor, Bay) = MpP_Mp;
                    AllEle.MpN_Mp(Floor, Bay) = MpN_Mp;
                    fprintf(INP, 'set compBackboneFactors [lreplace $compBackboneFactors 0 0 %8.4f];# MpP/Mp\n', MpP_Mp);
                    fprintf(INP, 'set compBackboneFactors [lreplace $compBackboneFactors 1 1 %8.4f];# MpN/Mp\n', MpN_Mp);
                    
                    % Write beam element
                    if ~fractureElement
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%         Traditional CPH           %%%%%%%%%%%
                    %%%%%%%%%   (No fracture fiber-section)     %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                                         
                        % Build element
                        fprintf(INP, 'hingeBeamColumn %d %d %d "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag %.3f [expr %.3f*$Comp_I] $degradation $c $secInfo_i $secInfo_j $Composite $compBackboneFactors;\n', ...
                            ElementID, node_i, node_j, A, Ieff);                                                
                    else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%   CPH + Fracturing fiber-section  %%%%%%%%%%%
                    %%%%%%%%%                                   %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

                        % Fracture base section geometry
                        connDataIdx = find(~isempty(strfind(webConnection.Size, beamSize{Floor-1, Bay}))); 
                        typeWeb = webConnection.Type{connDataIdx};
                        if strcmp(typeWeb, 'Welded')
                            % Welded web
                            dtab = webConnection.dtab(connDataIdx);                            
                            ttab = webConnection.tabThickness(connDataIdx);
                            tabLength = webConnection.tabLength(connDataIdx);
                            
                            fprintf(INP, 'set fracSecGeometry {%8.4f %8.4f %8.4f %8.4f %8.4f %8.3g};\n', ...
                            d, bf, tf, ttab, tabLength, dtab);   
                        else
                            % Bolted web
                            boltNum = webConnection.BoltNumber(connDataIdx);
                            boltDiameter = webConnection.BoltDiameter(connDataIdx);
                            bolSpacing = webConnection.bolSpacing(connDataIdx);
                            boltLocation = -(boltNum-1)/2*bolSpacing:bolSpacing:(boltNum-1)/2*bolSpacing;
                            ttab = webConnection.tabThickness(connDataIdx);
                            tabLength = webConnection.tabLength(connDataIdx);
                            Lc = webConnection.Lc(connDataIdx);                            
                            str = ['{ ', sprintf('%0.5g  ',boltLocation), '}'];                                                       
                            
                            fprintf(INP, 'set fracSecGeometry {%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %s %8.3g %8.3g 1.0};\n', ...
                            d, bf, tf, tw, ttab, tabLength, str, boltDiameter, Lc);
                        end                        
                        
                        % Compute Adjustment factor, k (Galvis et al. 2021)
                        span_depth = Lbeam/d;
                        % bounds for evaluating sigmCr adjustment
                        tcf_i = min(tcf_i, 2);
                        tcf_j = min(tcf_j, 2);
                        span_depth = min(span_depth, 10);
                        
                        if strcmp(generation, 'Pre_Northridge')
                            %%%%%%%%%%% Pre-Northridge factors %%%%%%%%%%%%
                            kBL = 1.26*(tcf_i/1.25)^0.50*(tf/0.7)^(-0.22);
                            kTL = 0.50*(tcf_i/1.25)^0.66*(tf/0.7)^(-0.33)*span_depth^(0.37);                        
                            kBR = 1.26*(tcf_j/1.25)^0.50*(tf/0.7)^(-0.22);
                            kTR = 0.50*(tcf_j/1.25)^0.66*(tf/0.7)^(-0.33)*span_depth^(0.37);
                        else
                            %%%%%%%%%%% Post-Northridge factors %%%%%%%%%%%
                            % Compute Panel zone demand-to-capacity ratio 
                            pzStrengthToCompare = 'yielding';
                            pzFormula = 'FEMA355D';
                            Vpz_Vp_i = panelZoneRatio(nBeams_i, pzStrengthToCompare, ...
                                pzFormula, FyCol, FyBeam, dc_i, bcf_i, tcf_i, ...
                                tPZ_i, d, Zz, Sz, LcolAvg, Lbeam);
                            Vpz_Vp_j = panelZoneRatio(nBeams_i, pzStrengthToCompare, ...
                                pzFormula, FyCol, FyBeam, dc_j, bcf_j, tcf_j, ...
                                tPZ_j, d, Zz, Sz, LcolAvg, Lbeam);
                            
                            kBL = 0.13*(tcf_i/1.25)^0.17*span_depth^0.67*Vpz_Vp_i^(-0.14);
                            kTL = 0.36*span_depth^0.22*(tf/0.7)^(-0.24);                        
                            kBR = 0.13*(tcf_j/1.25)^0.17*span_depth^0.67*Vpz_Vp_j^(-0.14);
                            kTR = 0.36*span_depth^0.22*(tf/0.7)^(-0.24);
                        end
                        % Build element
                        fprintf(INP, 'set kBL %.3f\n', kBL);
                        fprintf(INP, 'set kTL %.3f\n', kTL);
                        fprintf(INP, 'set kBR %.3f\n', kBR);
                        fprintf(INP, 'set kTR %.3f\n', kTR);
                        
                        fprintf(INP, 'hingeBeamColumnFracture %d %d %d "Horizontal" $trans_selected $n $Es $FyBeam $rigMatTag %.3f [expr %.3f*$Comp_I] $degradation $c $secInfo_i $secInfo_j "%s" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay%d_floor%d_i] [expr $kTL*$sigCrT_bay%d_floor%d_i] [expr $kBR*$sigCrB_bay%d_floor%d_j] [expr $kTR*$sigCrT_bay%d_floor%d_j] $FI_limB_bay%d_floor%d_i $FI_limT_bay%d_floor%d_i $FI_limB_bay%d_floor%d_j $FI_limT_bay%d_floor%d_j $Composite $compBackboneFactors $trib $tslab $bslab $AslabSteel $slabFiberMaterials;\n', ...
                        ElementID, node_i, node_j, A, Ieff, typeWeb, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor);                 
                        
%                         fprintf(INP, 'forceBeamColumnFracture %d %d %d "Horizontal" $trans_selected [expr $Es*$Comp_I] $FyBeam $rigMatTag "%s" $fracSecGeometry $fracSecMaterials [expr $kBL*$sigCrB_bay%d_floor%d_i] [expr $kTL*$sigCrT_bay%d_floor%d_i] [expr $kBR*$sigCrB_bay%d_floor%d_j] [expr $kTR*$sigCrT_bay%d_floor%d_j] $FI_limB_bay%d_floor%d_i $FI_limT_bay%d_floor%d_i $FI_limB_bay%d_floor%d_j $FI_limT_bay%d_floor%d_j $Composite $trib $tslab $bslab $AslabSteel $slabFiberMaterials $elemConvTol;\n', ...
%                             ElementID, node_i, node_j, typeWeb, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor, Bay, Floor);                 
                        
                    end
                end            
            end
        end
    end
    fprintf(INP, '\n');
end