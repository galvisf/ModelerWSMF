%% This function creates a file to perform Response Spectrum Analysis
% on a predefined frame model
% 
% 
function RSA(analysisFile, modelFN, spectraFN, n_modes_RSA, bldgData)
colSize = bldgData.colSize;
axisNum = bldgData.axisNum;

%% Create analysis file

% Name of the input file (delete existing files with same name)                   
filename = analysisFile;
if isfile(filename)
    delete(filename)
end
INP = fopen(filename,'w+');

%%%% Source main model file %%%%
fprintf(INP, 'source %s\n\n', modelFN);

%%%% Source response spectrum and create the function %%%
fprintf(INP, '# ----- RESPONSE SPECTRUM ----- #\n');
fprintf(INP, 'source %s\n', [spectraFN,'.tcl']);
fprintf(INP, 'set tsTag 1; # use the timeSeries 1 as response spectrum function\n');
fprintf(INP, 'timeSeries Path $tsTag -time $timeSeries_list_of_times_1 -values $timeSeries_list_of_values_1 -factor $g\n\n');

%%%% Modal analysis for RSA %%%
fprintf(INP, '# ----- MODAL ANALYSIS ----- #\n');
fprintf(INP, '# run the eigenvalue analysis with $modes_RSA modes and obtain the eigenvalues\n');
fprintf(INP, 'set modes_RSA %d\n', n_modes_RSA);
fprintf(INP, 'set eigs [eigen -genBandArpack $modes_RSA]\n\n');
fprintf(INP, '# compute the modal properties\n');
fprintf(INP, 'modalProperties -print -file "$outdir/ModalReport.txt" -unorm\n');

%%%% Write additional recorders for RSA analysis %%%
% Base shear (columns at the base or above basement if any)
fprintf(INP, '# ----- RECORDERS FOR RSA ----- #\n');

base_element = zeros(axisNum, 1);
text_base_element = ['recorder Element -file $outdir/RSA_base.out -closeOnWrite -precision 16 -ele '];
for Axis = 1:axisNum
    story_i = 1;
    if ~isempty(colSize{story_i, Axis})
        base_element(Axis) = 2e6+story_i*10000+Axis*100;
        text_base_element = strcat(text_base_element, ' %d');
    end
end
text_base_element = strcat(text_base_element, ' globalForce;\n\n');
fprintf(INP, '# Base shear columns recorders #\n');
fprintf(INP, text_base_element, base_element');

% Drift recorders
fprintf(INP, '# Drift recorders #\n');
fprintf(INP, 'for {set story 1} {$story <= $num_stories} {incr story} {\n');
fprintf(INP, '\trecorder Drift -file $outdir/story${story}_drift.out -closeOnWrite -precision 16 -iNode [lindex $ctrl_nodes [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2\n');
fprintf(INP, '}\n\n');

%% Write commands for RSA analysis
% define variables
stepNum  = 0;
tol      = 1e-4;
max_iter = 10; % the max number of iterations to check before returning failure condition

fprintf(INP, '# ----- ELF analyses commands ----- #\n');
fprintf(INP, 'constraints Plain;\n');
fprintf(INP, 'numberer Plain;\n');
fprintf(INP, 'system BandGeneral;\n');
fprintf(INP, 'test RelativeEnergyIncr %0.1e %d;\n', tol, max_iter);
fprintf(INP, 'algorithm Newton;\n');
fprintf(INP, 'integrator LoadControl %0.2f;\n', stepNum); % the load factor increment
fprintf(INP, 'analysis Static\n');
fprintf(INP, 'set direction 1; # excited DOF = Ux\n');
fprintf(INP, 'responseSpectrum $tsTag $direction\n');
fprintf(INP, 'wipeAnalysis;\n');
    
end