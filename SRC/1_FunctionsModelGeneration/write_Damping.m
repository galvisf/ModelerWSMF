%% This function assigns the elastic damping to the structure
%   
% Supports the following damping types:
%   'Rayleigh_k0_all'                = Typical proportional to initial
%                                      stiffness
%   'Rayleigh_k0_beams_cols'         = To only elastic beam and column
%                                      elements (prop. to initial stiffness) 
%                                      and nodes with mass
%   'Rayleigh_k0_beams_cols_springs' = To all elements modifying based on
%                                      Zareian and Medina (2010) modifications
%   'Rayleigh_kt_all'                = Typical proportional to tangent
%                                      stiffness
%   'Cruz_5'                         = To all elements based on Cruz (2017)
%   'Modal'                          = Typical modal damping
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
%
function write_Damping(INP,  AllEle, AllNodes, dampingType, backbone, ...
                    fractureElement, addSplices, panelZoneModel)

%% Assign damping
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                               DAMPING                                           #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n');

if length(dampingType) > 8 && strcmp(dampingType(1:8), 'Rayleigh')    
    fprintf(INP, '# Calculate Rayleigh Damping constnats\n');
    fprintf(INP, 'set wI [lindex $omegas $DampModeI-1]\n');
    fprintf(INP, 'set wJ [lindex $omegas $DampModeJ-1]\n');
    fprintf(INP, 'set a0 [expr $zeta*2.0*$wI*$wJ/($wI+$wJ)];\n');
    fprintf(INP, 'set a1 [expr $zeta*2.0/($wI+$wJ)];\n');
    
    if strcmp(backbone, 'Elastic')
        fprintf(INP, 'set a1_mod $a1;\n\n');
    else
        fprintf(INP, 'set a1_mod [expr $a1*(1.0+$n)/$n];\n\n');
    end
    
end

switch dampingType
    case 'Rayleigh_k0_all'
        fprintf(INP, 'rayleigh $a0 0.0 $a1 0.0;\n');
        
    case 'Rayleigh_k0_beams_cols'
        beamRngTag = 1; % region tag for beam element
        colRngTag = 2; % region tag for column element
        nodeMassRngTag = 3; % region tag for nodes
        
        % Elements to assign damping
        if isempty(AllEle.EGFcol) || isempty(AllEle.EGFbeam)
            column_list = AllEle.col(:,1);
            beam_list = AllEle.beam(:,1);
        else
            column_list = [AllEle.col(:,1);AllEle.EGFcol(:,1)];
            beam_list = [AllEle.beam(:,1);AllEle.EGFbeam(:,1)];
        end
        
        % Nodes with structural mass (1~4 in each PZ)
        node_list = AllNodes.mass(:,1);    
        
        % Assign damping to beam elastic elements
        fprintf(INP, '\n# Beam elastic elements\n');
        fprintf(INP, 'region %d -ele', beamRngTag);
        for beam_i = 1:length(beam_list)
            fprintf(INP, ' %d', beam_list(beam_i));
        end
        fprintf(INP, ' -rayleigh 0.0 0.0 $a1 0.0;\n');
        
        % Assign damping to column elastic elements
        fprintf(INP, '\n# Column elastic elements\n');
        fprintf(INP, 'region %d -ele', colRngTag);
        for col_i = 1:length(column_list)
            fprintf(INP, ' %d', column_list(col_i));
        end
        
        % Assign damping to column second elastic elements (for splices)
        if addSplices
            column_list = AllEle.colSplice;
            for col_i = 1:length(column_list)
                fprintf(INP, ' %d', column_list(col_i)+2);
            end
        end
        fprintf(INP, ' -rayleigh 0.0 0.0 $a1 0.0;\n');
        
        % Assign damping to nodes with mass
        fprintf(INP, '\nNodes with mass\n');
        fprintf(INP, 'region %d -nodes', nodeMassRngTag);
        for n_i = 1:length(node_list)
            fprintf(INP, ' %d', node_list(n_i));
        end
        fprintf(INP, ' -rayleigh $a0 0.0 0.0 0.0;\n');
case 'Rayleigh_k0_beams_cols_springs'
        beamRngTag     = 1; % region tag for beam element
        colRngTag      = 2; % region tag for column element
        hingeRngTag    = 3; % region tag for plastic hinge elements
        nodeMassRngTag = 4; % region tag for nodes
        fracRngTag     = 5; % region tag for column element        
        spliceRngTag   = 6; % region tag for column element
        pzRngTag       = 7; % region tag for column element
        
        % Elements to assign damping
        if isempty(AllEle.EGFcol) || isempty(AllEle.EGFbeam)
            column_list = AllEle.col(:,1);
            beam_list = AllEle.beam(:,1);
        else
            column_list = [AllEle.col(:,1);AllEle.EGFcol(:,1)];
            beam_list = [AllEle.beam(:,1);AllEle.EGFbeam(:,1)];
        end
        if ~strcmp(panelZoneModel, 'None')
            pz_list = AllEle.pzSprings(:,1);
        end
        
        % Nodes with structural mass
        node_list = AllNodes.mass(:,1);
        
        % Assign damping to beam elastic elements
        fprintf(INP, '\n# Beam elastic elements\n');
        fprintf(INP, 'region %d -ele', beamRngTag);
        for beam_i = 1:length(beam_list)
            fprintf(INP, ' %d', beam_list(beam_i));
        end
        fprintf(INP, ' -rayleigh 0.0 0.0 $a1_mod 0.0;\n');
        
        % Assign damping to column elastic elements
        fprintf(INP, '\n# Column elastic elements\n');
        fprintf(INP, 'region %d -ele', colRngTag);
        for col_i = 1:length(column_list)
            fprintf(INP, ' %d', column_list(col_i));
        end
        
        % Assign damping to column second elastic elements (for splices)
        if addSplices
            column_splice_list = AllEle.colSplices;
            for col_i = 1:length(column_splice_list)
                fprintf(INP, ' %d', column_splice_list(col_i)+2);
            end
        end
        fprintf(INP, ' -rayleigh 0.0 0.0 $a1_mod 0.0;\n');
        
        % Assign damping to plastic hinge springs
        fprintf(INP, '\n# Hinge elements [beam springs, column springs]\n');
        if ~strcmp(backbone, 'Elastic') 
            
            % Assign damping to beam springs
            fprintf(INP, 'region %d -ele', hingeRngTag);
            if fractureElement
                % Hinge elements
                for beam_i = 1:length(beam_list)
                    fprintf(INP, ' %d %d', beam_list(beam_i)+2, beam_list(beam_i)+4);
                end                              
            else
                % Hinge elements
                for beam_i = 1:length(beam_list)
                    fprintf(INP, ' %d %d', beam_list(beam_i)+1, beam_list(beam_i)+2);
                end
            end            
            % Assign damping to column springs            
            if addSplices                
                % Hinge elements
                columns_noSplice_list = setdiff(column_list,column_splice_list);
                for col_i = 1:length(columns_noSplice_list)
                    fprintf(INP, ' %d %d', columns_noSplice_list(col_i)+1, columns_noSplice_list(col_i)+2);
                end
            else
                % Hinge elements
                for col_i = 1:length(column_list)
                    fprintf(INP, ' %d %d', column_list(col_i)+1, column_list(col_i)+2);
                end
            end
            fprintf(INP, ' -rayleigh 0.0 0.0 [expr $a1_mod/$n] 0.0;\n');                        
        end
        
        % Adding damping to these elements causes HUGE errors due to
        % sporious damping forces
%         % Assign damping to fracture, splice, and panel zone springs        
%         if ~strcmp(backbone, 'Elastic')
%             % Fracture springs                                 
%             if fractureElement
%                 fprintf(INP, '\n# Fracture springs [beam springs, column springs]\n');
%                 fprintf(INP, 'region %d -ele', fracRngTag);  
%                 for beam_i = 1:length(beam_list)
%                     fprintf(INP, ' %d %d', beam_list(beam_i)+5, beam_list(beam_i)+6);
%                 end
%                 fprintf(INP, ' -rayleigh 0.0 0.0 $a1 0.0;\n');
%             end
%             % splice springs
%             if addSplices
%                 fprintf(INP, '\n# Splice springs []\n');
%                 fprintf(INP, 'region %d -ele', spliceRngTag);                 
%                 column_splice_list = AllEle.colSplices;
%                 for col_i = 1:length(column_splice_list)
%                     fprintf(INP, ' %d %d %d', column_splice_list(col_i)+3,column_splice_list(col_i)+4,column_splice_list(col_i)+5);
%                 end
%                 fprintf(INP, ' -rayleigh 0.0 0.0 $a1 0.0;\n');
%             end
%             % PZ springs
%             if ~strcmp(panelZoneModel, 'None')
%                 fprintf(INP, '\n# Panel zone springs []\n');
%                 fprintf(INP, 'region %d -ele', pzRngTag); 
%                 for pz_i = 1:length(pz_list)
%                     fprintf(INP, ' %d', pz_list(pz_i));
%                 end
%                 fprintf(INP, ' -rayleigh 0.0 0.0 $a1 0.0;\n');
%             end
%         end

        % Assign damping to nodes with mass
        fprintf(INP, '\n# Nodes with mass\n');
        fprintf(INP, 'region %d -nodes', nodeMassRngTag);
        for n_i = 1:length(node_list)
            fprintf(INP, ' %d', node_list(n_i));
        end
        fprintf(INP, ' -rayleigh $a0 0.0 0.0 0.0;\n');
        
    case 'Rayleigh_kt_all'
        fprintf(INP, 'rayleigh $a0 $a1 0.0 0.0;\n');
        
    case 'Cruz_5'
        N_modes = 5;
        for n_i = 1:N_modes-1
            fprintf(INP, 'set xi_%d [expr %0.3f*(0.92 + 0.12*pow([lindex $omegas %d], 2)/(pow([lindex $omegas 0], 2)))];\n', [n_i, zeta, n_i]);
%             fprintf(INP, '\tputs "$xi_%d";\n', n_i);
        end        
        fprintf(INP, 'modalDamping %0.3f', zeta);
        for n_i = 1:N_modes-1
            fprintf(INP, ' $xi_%d', n_i);
        end
        fprintf(INP, '\n');
    
    otherwise
        fprintf(INP, 'modalDamping $zeta;\n');
end
fprintf(INP, '\n');

end