%% This function creates the a support tcl file that defines the recorders for columns
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function write_ColumnRecorders(INP, AllEle, backbone, addSplices, isRHA)

column_list = AllEle.col(:,1);

fprintf(INP, 'if {$addDetailedRecorders == 1} {\n\n');
% Create recorders for columns element forces (axial, shear, moment)

fprintf(INP, '\t# Recorders for column internal forces\n');
if isRHA
    fprintf(INP, '\trecorder Element -file $outdir/column_forces.out -dT 0.01 -ele '); %  -dT 0.005
else
    fprintf(INP, '\trecorder Element -file $outdir/column_forces.out -closeOnWrite -precision 8 -ele ');
end
for col_i = 1:length(column_list)
    fprintf(INP, '%d ', column_list(col_i));
end
fprintf(INP,'globalForce;\n\n');

fprintf(INP, '}\n\n');

if addSplices
    column_splice_list = AllEle.colSplices;
    columns_noSplice_list = setdiff(column_list,column_splice_list);
    
    splice_tags = column_splice_list + 5;
    
    fprintf(INP, 'if {$addBasicRecorders == 1} {\n\n');
    
    %% Build Splice recorders
    % Create stressStrain recorders for splice elements
    fprintf(INP, '\t# Recorders column splices\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/ss_splice.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/ss_splice.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(splice_tags)
        fprintf(INP, '%d ', splice_tags(col_i));
    end
    %     fprintf(INP,'section 3 fiber -30.0 0.0 stressStrain;\n'); % targets the middle section of the 5-section forceBasedElement that represents the splice
    fprintf(INP,'section fiber 0 stressStrain;\n\n');
    
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/def_splice.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/def_splice.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(splice_tags)
        fprintf(INP, '%d ', splice_tags(col_i));
    end
    %     fprintf(INP,' plasticDeformation;\n\n');
    fprintf(INP,' deformation;\n\n');
        
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/force_splice.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/force_splice.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(splice_tags)
        fprintf(INP, '%d ', splice_tags(col_i));
    end
    %     fprintf(INP,' plasticDeformation;\n\n');
    fprintf(INP,' localForce;\n\n');
    
    fprintf(INP, '}\n\n');
end

if ~strcmp(backbone, 'Elastic')
    if addSplices
        hinge_tags_bot = [column_splice_list + 3; columns_noSplice_list + 1];
        hinge_tags_top = [column_splice_list + 4; columns_noSplice_list + 2];
    else
        hinge_tags_bot = column_list + 1;
        hinge_tags_top = column_list + 2;
    end
    
    %% Build column recorders
    fprintf(INP, 'if {$addBasicRecorders == 1} {\n\n');
    
    % Create recorders for hinge deformations (axial, shear, rotation)
    fprintf(INP, '\t# Recorders column hinges\n');
    fprintf(INP, '\t# Bottom\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_bot.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_bot.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(hinge_tags_bot)
        fprintf(INP, '%d ', hinge_tags_bot(col_i));
    end
    fprintf(INP,'deformation;\n');
    
    fprintf(INP, '\t# Top\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_top.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_top.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(hinge_tags_top)
        fprintf(INP, '%d ', hinge_tags_top(col_i));
    end
    fprintf(INP,'deformation;\n');
    
    fprintf(INP, '}\n\n');
    
    
    
    fprintf(INP, 'if {$addDetailedRecorders == 1} {\n\n');
    
    % Create recorders for hinge forces (axial, shear, rotation)
    fprintf(INP, '\t# Bottom\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_bot_force.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_bot_force.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(hinge_tags_bot)
        fprintf(INP, '%d ', hinge_tags_bot(col_i));
    end
    fprintf(INP,'force;\n');
    
    fprintf(INP, '\t# Top\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/hinge_top_force.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/hinge_top_force.out -closeOnWrite -precision 8 -ele ');
    end
    for col_i = 1:length(hinge_tags_top)
        fprintf(INP, '%d ', hinge_tags_top(col_i));
    end
    fprintf(INP,'force;\n');
    
    fprintf(INP, '}\n\n');
    
end



