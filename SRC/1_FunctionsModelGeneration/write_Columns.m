%% This function writes the code to call the procedure that builds the columns
%
% Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function AllEle = write_Columns(INP,AllEle,bldgData,AISC_v14p1,addSplices,...
                            backbone, degradation,Es,FyCol,cvn_col)
    %% Read relevant variables
    storyNum       = bldgData.storyNum;
    axisNum        = bldgData.axisNum;
    bayNum         = bldgData.bayNum;
    colSize        = bldgData.colSize;
    beamSize       = bldgData.beamSize;
    colAxialLoad   = bldgData.colAxialLoad;
    colSplice      = bldgData.colSplice;
    storyHgt       = bldgData.storyHgt;
    spliceFraction = bldgData.spliceFraction;
    colOrientations = bldgData.colOrientations;
    
    AllEle.col = []; % Matrix with element data for plots
    AllEle.colSplices = []; % List of element IDs with splices
    AllEle.Mn_Mp_col = zeros(storyNum, axisNum);    
    
    %%
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'#                                            COLUMNS ELEMENTS                                      #\n');
    fprintf(INP,'####################################################################################################\n');
    fprintf(INP,'\n');
    
    fprintf(INP,'# COMMAND SYNTAX \n');
    if strcmp(backbone, 'Elastic')
        fprintf(INP,'# element elasticBeamColumn   ElementID node_i node_j ...\n');                            
    else
        fprintf(INP,'# secInfo  Zp, Mc/Mp, Mr/Mp, theta_p, theta_pc, theta_u, lambda\n');
        fprintf(INP,'# spliceSecGeometry  min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j)\n'); 
        fprintf(INP,'# (splice)    hingeBeamColumnSplice  ElementID node_i node_j eleDir, ... A, Ieff, ... \n');  
        fprintf(INP,'# (no splice) hingeBeamColumn        ElementID node_i node_j eleDir, ... A, Ieff\n');  
    end
    
    % Compute properties and write each column
    for Axis = 1:axisNum               
        storiesDone = zeros(storyNum, 1); % counter for columns spanning multiple stories                             
        
        for Story = 1:storyNum
            isBox_i = false;
            isBox_j = false;
            
            if ~isempty(colSize{Story, Axis}) && ~ismember(Story, storiesDone)
                % Floor bottom end
                Floor_i = Story;
                
                % Find Floor for top end (in case of missing beams the column spans multiple stories)
                Floor_j = 0;
                i = 0;
                while Floor_j == 0
                    if ~isempty(beamSize{Story+i, max(Axis-1,1)}) || ~isempty(beamSize{Story+i, min(Axis,bayNum)})
                        Floor_j = Story+i+1;
                    else
                        i = i + 1;
                    end
                end
                if Floor_j == Story+1
                    fprintf(INP, '\n# Columns at story %d axis %d\n', Story, Axis);
                else
                    fprintf(INP, '\n# Columns at story %d to %d Axis %d\n', Story, Floor_j-1, Axis);
                end
                storiesDone(Floor_i:Floor_j-1) = Floor_i:Floor_j-1;
                
                % Element and node labels
                ElementID = 2e6 + Story*10000 + Axis*100;
                if Floor_i == 1
                    node_i = 1*10000+Axis*100; % bottom end (ground)
                else
                    node_i = 4000000 + Floor_i*1e4 + Axis*100 + 3; % bottom end
                end
                node_j = 4000000 + Floor_j*1e4 + Axis*100 + 1; % top end
                
                % Save data for plot
                nodeCL_i = Floor_i*10000+Axis*100;
                nodeCL_j = Floor_j*10000+Axis*100;
                AllEle.col = [AllEle.col; ElementID, nodeCL_i, nodeCL_j];                                
                
                % Column properties (upper end)                
                props_j = getSteelSectionProps(colSize{Floor_j-1, Axis}, AISC_v14p1);
                A_j = props_j.A;
                d_j = props_j.db;
                tw_j = props_j.tw;
                tf_j = props_j.tf;
                bf_j = props_j.bf;
                Iz_j = props_j.Iz;
                Zz_j = props_j.Zz;
                Zy_j = props_j.Zy;
                Sz_j = props_j.Sz;
                Sy_j = props_j.Sy;
                Iy_j = props_j.Iy; 
                r_y_j = sqrt(Iy_j/props_j.A);
                h_tw_j = props_j.h_tw;
                if strcmp(colSize{Floor_j-1, Axis}(1:3), 'BOX')
                    isBox_i = true;
                    tw_j = 2*tw_j; % to consider both webs
                end
                % Column properties (upper end) 
                if Story ~= 1
                    props_i = getSteelSectionProps(colSize{Floor_i, Axis}, AISC_v14p1);
                    A_i = props_i.A;                    
                    d_i = props_i.db;
                    tw_i = props_i.tw;
                    tf_i = props_i.tf;
                    bf_i = props_i.bf;
                    Iz_i = props_i.Iz;
                    Zz_i = props_i.Zz;
                    Iy_i = props_i.Iy;
                    if strcmp(colSize{Floor_i, Axis}(1:3), 'BOX')
                        isBox_j = true;
                        tw_i = 2*tw_i; % to consider both webs
                    end
                else
                    props_i = props_j;
                    A_i = A_j;
                    d_i = d_j;
                    tw_i = tw_j;
                    tf_i = tf_j;
                    Iz_i = Iz_j;
                    bf_i = bf_j;
                    Zz_i = Zz_j;
                    Iy_i = props_i.Iy;
                    isBox_i = isBox_j;
                    if isBox_i
                        tw_i = 2*tw_i; % to consider both webs
                    end
                end 

                % Lower beam properties (assumes the same beam for the whole floor based on 1st bay)            
                if Story ~= 1
                    props = getSteelSectionProps(beamSize(Story-1,bayNum), AISC_v14p1);
                    db_i = props.db;
                else
                    db_i = 0;
                end
                
                % Upper beam properties (assumes the same beam for the whole floor based on 1st bay)            
                props = getSteelSectionProps(beamSize(Floor_j-1,bayNum), AISC_v14p1);            
                db_j = props.db;                

                % Column length            
                Lcol = sum(storyHgt(Floor_i:Floor_j-1)) - db_i/2 - db_j/2; 
                
                % Axial load ratio                 
                Pg = colAxialLoad(Floor_i, Axis);
%                 axialLoadRatio = [axialLoadRatio; Pg/(mean([props.A, props.A])*FyCol)];
                
                % Write columns in model file
                if strcmp(backbone, 'Elastic')
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%           Elastic model           %%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Effective Elastic stiffness (to account for shear deformation) - ASSUMED
                    % COLUMN IS FIXED-FIXED
                    % Stiffness reduction for axial load (ASCE41-17 9-5)
                    Pye = mean([A_i, A_j])*FyCol;
                    if Pg/Pye <= 0.5
                        t_b = 1.0;
                    else
                        t_b = 4*Pg/Pye*(1 - Pg/Pye);
                    end
                    if colOrientations(Story,Axis) == 1 % strong
                        Aw = mean([tw_i,tw_j])*mean([d_i,d_j]);
                        I = mean([Iz_i, Iz_j]);
                    else % weak
                        Aw = 2*mean([tf_i,tf_j])*mean([bf_i,bf_j]);
                        I = mean([Iy_i, Iy_j]);
                    end                    
                    G = Es/(2*(1+0.3));
                    L = Lcol/2;              % Shear spam (half the length)
                    Ks = G*Aw/L;             % Shear lateral stiffness of the column
                    Kb = 12*Es*I*t_b/Lcol^3;    % bending lateral stiffness of the column
                    Ke = Ks*Kb/(Ks+Kb);      % effective lateral stiffness
                    EIeff = Ke*Lcol^3/12;    % effective EI to use in element without shear deformation in its formulation
                    Ieff = EIeff/Es;         % effective I to use in element without shear deformation in its formulation
                    
                    % Write column element
                    if colSplice(Story, Axis) == 0 || ~addSplices
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%            NO SPLICE              %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
                        fprintf(INP,'set A   %.3f\n', mean([A_i, A_j]));
                        fprintf(INP,'set Ieff   %.3f\n', Ieff);
                        fprintf(INP,'element elasticBeamColumn   %d %d %d $A $Es $Ieff $trans_selected\n',ElementID, node_i, node_j);
                    else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%             SPLICE                %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                        % Build element
                        fprintf(INP, 'set ttab %.3f\n', tw_i); % Assume the tab has at least the bottom section thickness
                        dtab = min(d_i - 2*tf_i, d_j - 2*tf_j)*0.7; % Assume tab in 70% of the web depth
                        fprintf(INP, 'set dtab %.3f\n', dtab);
                        
%                         fprintf(INP, 'set spliceSecGeometry {%8.4f %8.4f %8.4f %8.4f };\n', ...
%                         min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j));                                                                        
%                         fprintf(INP, 'elasticBeamColumnSpliceFiber %d %d %d "Vertical" $trans_selected $Es $rigMatTag $A $Ieff $spliceLoc $spliceSecGeometry $ttab $dtab;\n', ...
%                             ElementID, node_i, node_j);
                        
                        
                        fprintf(INP, 'elasticBeamColumnSplice %d %d %d "Vertical" $trans_selected $Es $A $Ieff $spliceLoc;\n', ...
                            ElementID, node_i, node_j);
                        
                        AllEle.colSplices = [AllEle.colSplices; ElementID];
                    end
                    
                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%         Inelastic model           %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Hinge properties
                    % Lower hinge                    
                    [Ieff_i, Mp_i, McMp_i, MrMp_i, theta_p_i, theta_pc_i, theta_u_i, lambda_i, ~] = ...
                        steelColumnHinge(isBox_i, backbone, degradation, colOrientations(Story,Axis), ...
                        props_i, Lcol, FyCol, Es, Pg);
                    % Upper hinge
                    [Ieff_j, Mp_j, McMp_j, MrMp_j, theta_p_j, theta_pc_j, theta_u_j, lambda_j, ~] = ...
                        steelColumnHinge(isBox_j, backbone, degradation, colOrientations(Story,Axis), ...
                        props_j, Lcol, FyCol, Es, Pg);
                    Ieff = mean([Ieff_i, Ieff_j]); 
                    
                    AllEle.Mn_Mp_col(Story, Axis) = mean([Mp_i/(Zz_i*FyCol), Mp_j/(Zz_j*FyCol)]);
                    
                    % Write column section data
                    Zp_i = Mp_i/FyCol; % this captures the strain hardening factor added in the steelColumnHinge function
                    Zp_j = Mp_j/FyCol; 
                    fprintf(INP, 'set secInfo_i {%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f};\n', ...
                        Zp_i, McMp_i, MrMp_i, theta_p_i, theta_pc_i, theta_u_i, lambda_i);
                    fprintf(INP, 'set secInfo_j {%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f};\n', ...
                        Zp_j, McMp_j, MrMp_j, theta_p_j, theta_pc_j, theta_u_j, lambda_j);
                    
                    % Write column element
                    if colSplice(Story, Axis) == 0 || ~addSplices
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%         Traditional CPH           %%%%%%%%%%%
                    %%%%%%%%%           (NO SPLICE)             %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                                         
                        % Build element
                        fprintf(INP, 'hingeBeamColumn %d %d %d "Vertical" $trans_selected $n $Es $FyCol $rigMatTag %.3f %.3f $degradation $c $secInfo_i $secInfo_j 0 0;\n', ...
                            ElementID, node_i, node_j, mean([A_i, A_j]), Ieff);                                                
                    else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%         Traditional CPH           %%%%%%%%%%%
                    %%%%%%%%%            (SPLICE)               %%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                        % compute splice material fractura properties
                        a0 = (1-spliceFraction)*tf_j; % length of the flange NOT welded
                        sigCr = fractureModelPropsSplice(cvn_col, a0, Es, FyCol, d_j, tf_j); 
                        % Build element
                        fprintf(INP, 'set sigCr %.3f\n', sigCr);
                        fprintf(INP, 'set ttab %.3f\n', tw_i); % Assume the tab has at least the bottom section thickness
                        dtab = min(d_i - 2*tf_i, d_j - 2*tf_j)*0.7; % Assume tab in 70% of the web depth
                        fprintf(INP, 'set dtab %.3f\n', dtab);
                        fprintf(INP, 'set spliceSecGeometry {%8.4f %8.4f %8.4f %8.4f };\n', ...
                        min(d_i, d_j), min(bf_i, bf_j), min(tf_i, tf_j), min(tw_i, tw_j));                                                                        
                        fprintf(INP, 'hingeBeamColumnSpliceZLS %d %d %d "Vertical" $trans_selected $n $Es $FyCol $rigMatTag %.3f %.3f $degradation $c $secInfo_i $secInfo_j $spliceLoc $spliceSecGeometry $FyCol $sigCr $ttab $dtab;\n', ...
                            ElementID, node_i, node_j, mean([A_i, A_j]), Ieff);
                        AllEle.colSplices = [AllEle.colSplices; ElementID];
                    end
                end          
            end
        end
    end
    fprintf(INP, '\n');
end