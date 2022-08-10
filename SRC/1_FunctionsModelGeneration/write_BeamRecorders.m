%% This function creates defines the recorders for beams
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function write_BeamRecorders(INP, AllEle, fractureElement, backbone, isRHA)

beam_list = AllEle.beam(:,1);
n_beams = length(beam_list);

if ~strcmp(backbone, 'Elastic')
    
    if fractureElement
        beam_tags_left = beam_list + 5;
        beam_tags_right = beam_list + 6;
        hinge_tags_left = beam_list + 2;
        hinge_tags_right = beam_list + 4;
    else
        hinge_tags_left = beam_list + 1;
        hinge_tags_right = beam_list + 2;
    end
    
    %% Build beam recorders
    
    if fractureElement
        
        fprintf(INP, 'if {$addBasicRecorders == 1} {\n\n');
        
        % Create recorders for fracture boolean
        fprintf(INP, '\t# Recorders for beam fracture boolean\n');
        fprintf(INP, '\t# Left-bottom flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/frac_LB.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/frac_LB.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        %         fprintf(INP,'section fiber -30.0 0.0 failure;\n');
        fprintf(INP,'section fiber 7 failure;\n');
        
        fprintf(INP, '\n\t# Left-top flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/frac_LT.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/frac_LT.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 2 failure;\n');
        
        fprintf(INP, '\n\t# Right-bottom flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/frac_RB.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/frac_RB.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 7 failure;\n');
        
        fprintf(INP, '\n\t# Right-top flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/frac_RT.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/frac_RT.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 2 failure;\n\n');
        
        % Create recorders for fracture index
        fprintf(INP, '\t# Recorders for beam fracture index\n');
        fprintf(INP, '\t# Left-bottom flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/FI_LB.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/FI_LB.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 7 damage;\n');
        
        fprintf(INP, '\n\t# Left-top flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/FI_LT.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/FI_LT.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 2 damage;\n');
        
        fprintf(INP, '\n\t# Right-bottom flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/FI_RB.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/FI_RB.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 7 damage;\n');
        
        fprintf(INP, '\n\t# Right-top flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/FI_RT.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/FI_RT.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 2 damage;\n\n');
        
        fprintf(INP, '}\n\n');
        
        
        
        
        fprintf(INP, 'if {$addDetailedRecorders == 1} {\n\n');
        
        % Create recorders for stress-strain histories
        fprintf(INP, '\t# Recorders for beam fracture index\n');
        fprintf(INP, '\t# Left-bottom flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/ss_LB.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/ss_LB.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 7 stressStrain;\n');
        
        fprintf(INP, '\n\t# Left-top flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/ss_LT.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/ss_LT.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 2 stressStrain;\n');
        
        fprintf(INP, '\n\t# Right-bottom flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/ss_RB.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/ss_RB.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 7 stressStrain;\n');
        
        fprintf(INP, '\n\t# Right-top flange\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/ss_RT.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/ss_RT.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 2 stressStrain;\n\n');
        
        % Create recorders for slab fibers
        fprintf(INP, '\t# Recorders for slab fiber stressStrain\n');
        fprintf(INP, '\n\t# Left-Concrete\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/slabComp_L.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/slabComp_L.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 10 stressStrain;\n');
        
        fprintf(INP, '\n\t# Left-Steel\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/slabTen_L.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/slabTen_L.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 11 stressStrain;\n');
        
        fprintf(INP, '\n\t# Right-Concrete\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/slabComp_R.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/slabComp_R.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 10 stressStrain;\n');
        
        fprintf(INP, '\n\t# Right-Steel\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/slabTen_R.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/slabTen_R.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 11 stressStrain;\n\n');
        
        % Create recorders for tab-web-bolt fibers
        fprintf(INP, '\t# Recorders for web fibers\n');
        fprintf(INP, '\n\t# Left-web1\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L1.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L1.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 12 stressStrain;\n');
        
        fprintf(INP, '\n\t# Left-web2\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L2.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L2.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 13 stressStrain;\n');
        
        fprintf(INP, '\n\t# Left-web3\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L3.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L3.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 14 stressStrain;\n\n');
        
        fprintf(INP, '\n\t# Left-web4\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L4.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_L4.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section fiber 15 stressStrain;\n\n');
        
        fprintf(INP, '\n\t# Right-web1\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R1.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R1.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 12 stressStrain;\n');
        
        fprintf(INP, '\n\t# Right-web2\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R2.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R2.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 13 stressStrain;\n');
        
        fprintf(INP, '\n\t# Right-web3\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R3.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R3.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 14 stressStrain;\n\n');
        
        fprintf(INP, '\n\t# Right-web4\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R4.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/webfiber_R4.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section fiber 15 stressStrain;\n\n');
        
        % Create recorders for fracture element deformations (axial, shear, rotation)
        fprintf(INP, '\t# Recorders beam fiber-section element\n');
        fprintf(INP, '\n\t# Left\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/def_left.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/def_left.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_left(beam_i));
        end
        fprintf(INP,'section deformation;\n');
        
        fprintf(INP, '\n\t# Right\n');
        if isRHA
            fprintf(INP, '\trecorder Element -file $outdir/def_right.out -dT 0.01 -ele '); % -dT 0.005
        else
            fprintf(INP, '\trecorder Element -file $outdir/def_right.out -closeOnWrite -precision 16 -ele ');
        end
        for beam_i = 1:n_beams
            fprintf(INP, '%d ', beam_tags_right(beam_i));
        end
        fprintf(INP,'section deformation;\n\n');
        
        fprintf(INP, '}\n\n');
    end
    
    % Create recorders for hinge deformations (axial, shear, rotation)
    fprintf(INP, 'if {$addBasicRecorders == 1} {\n\n');
    
    fprintf(INP, '\t# Recorders beam hinge element\n');
    fprintf(INP, '\n\t# Left\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_left.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_left.out -closeOnWrite -precision 16 -ele ');
    end
    for beam_i = 1:n_beams
        fprintf(INP, '%d ', hinge_tags_left(beam_i));
    end
    fprintf(INP,'deformation;\n');
    
    fprintf(INP, '\n\t# Right\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_right.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_right.out -closeOnWrite -precision 16 -ele ');
    end
    for beam_i = 1:n_beams
        fprintf(INP, '%d ', hinge_tags_right(beam_i));
    end
    fprintf(INP,'deformation;\n');
    
    fprintf(INP, '}\n\n');
    
    % Create recorders for hinge forces (axial, shear, rotation)
    fprintf(INP, 'if {$addDetailedRecorders == 1} {\n\n');
    
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_right_force.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_right_force.out -closeOnWrite -precision 16 -ele ');
    end
    for beam_i = 1:n_beams
        fprintf(INP, '%d ', hinge_tags_right(beam_i));
    end
    fprintf(INP,'force;\n\n');
    
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_left_force.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_left_force.out -closeOnWrite -precision 16 -ele ');
    end
    for beam_i = 1:n_beams
        fprintf(INP, '%d ', hinge_tags_left(beam_i));
    end
    fprintf(INP,'force;\n');
    
    fprintf(INP, '}\n\n');
end

fprintf(INP, 'if {$addDetailedRecorders == 1} {\n\n');
% Create recorders for beam element forces (axial, shear, rotation)
fprintf(INP, '\t# Recorders for beam internal forces\n');
if isRHA
    fprintf(INP, '\trecorder Element -file $outdir/beam_forces.out -dT 0.01 -ele '); % -dT 0.005
else
    fprintf(INP, '\trecorder Element -file $outdir/beam_forces.out -closeOnWrite -precision 16 -ele ');
end
for beam_i = 1:n_beams
    fprintf(INP, '%d ', beam_list(beam_i));
end
fprintf(INP,'globalForce;\n\n');

fprintf(INP, '}\n\n');

end



