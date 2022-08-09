%% This function creates the recorders for the PZforces
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function write_PZrecorders(INP, AllNodes, panelZoneModel, isRHA)

if ~strcmp(panelZoneModel, 'None')
    
    pz_tag = AllNodes.CL(:, 1) + 9000000;
    
    % Create recorders for panel zone rotations
    fprintf(INP, 'if {$addBasicRecorders == 1} {\n\n');
    
    fprintf(INP, '\t# Recorders panel zone elements\n');
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/pz_rot.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/pz_rot.out -closeOnWrite -precision 16 -ele ');
    end
    
    for pz_i = 1:length(pz_tag)
        fprintf(INP, '%d ', pz_tag(pz_i));
    end
    fprintf(INP,'deformation;\n');
    
    fprintf(INP, '}\n\n');
     
     
    fprintf(INP, 'if {$addDetailedRecorders == 1} {\n\n');
    % Create recorders for panel zone moment
    if isRHA
        fprintf(INP, '\trecorder Element -file $outdir/pz_M.out -dT 0.01 -ele '); % -dT 0.005
    else
        fprintf(INP, '\trecorder Element -file $outdir/pz_M.out -closeOnWrite -precision 16 -ele ');
    end
    for pz_i = 1:length(pz_tag)
        fprintf(INP, '%d ', pz_tag(pz_i));
    end
    fprintf(INP,'force;\n');   
    fprintf(INP, '}\n\n');
    
end

end



