%% This function creates a file to perform equivalent lateral load analysis
% on a predefined frame model
% 
% 
function ELFP(analysisFile, modelFN, Fx_pattern, bldgData)
colSize = bldgData.colSize;
axisNum = bldgData.axisNum;

%% Create analysis file

% Name of the input file (delete existing files with same name)                   
filename = analysisFile;
if exist(filename, 'file')
    delete(filename)
end
INP = fopen(filename,'w+');

%%%% Source main model file %%%%
fprintf(INP, 'source %s\n\n', modelFN);

%%%% Write lateral load pattern %%%
fprintf(INP, '# ----- LATERAL LOAD PATTERN ----- #\n');
fprintf(INP, 'source %s\n\n', [Fx_pattern,'.tcl']);

fprintf(INP, '# create load pattern for lateral load when using linear load pattern\n');
fprintf(INP, 'pattern Plain 300 Linear {;			# define load pattern\n');
fprintf(INP, '\tfor {set level 2} {$level <=[expr $num_stories]} {incr level 1} {\n');
fprintf(INP, '\t\tset Fi [expr [lindex $iFi [expr $level-1]]];		# lateral load coefficient\n');
fprintf(INP, '\t\t# all force in right column (that is continuous from bottom to top)\n');
fprintf(INP, '\t\tset nodeID [lindex $ctrl_nodes $level]\n'); %[expr 10000*$level + ($NBay+1)*100]
fprintf(INP, '\t\t# puts "$nodeID"\n');
fprintf(INP, '\t\tload $nodeID $Fi 0.0 0.0\n');
fprintf(INP, '\t}\n');
fprintf(INP, '}\n');

%%%% Write recorders for ELF analysis %%%
% Base shear (columns at the base or above basement if any)
fprintf(INP, '# ----- RECORDERS FOR ELF ----- #\n');

base_element = zeros(axisNum, 1);
text_base_element = ['recorder Element -file $outdir/EPL_base.out -ele '];
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
fprintf(INP, '\trecorder EnvelopeDrift -file $outdir/story${story}_drift_env.out -iNode [lindex $ctrl_nodes [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2\n');
fprintf(INP, '}\n\n');

%% Write commands for ELF analysis

% define variables
stepNum  = 10;
tol      = 1e-12;
max_iter = 20; % the max number of iterations to check before returning failure condition

fprintf(INP, '# ----- ELF analyses commands ----- #\n');
fprintf(INP, 'constraints Plain;\n');
fprintf(INP, 'numberer Plain;\n');
fprintf(INP, 'system BandGeneral;\n');
fprintf(INP, 'test RelativeEnergyIncr %0.1e %d;\n', tol, max_iter);
fprintf(INP, 'algorithm Newton;\n');
fprintf(INP, 'integrator LoadControl %0.6f;\n', 1/stepNum); % the load factor increment
fprintf(INP, 'analysis Static;\n');
fprintf(INP, 'if {[analyze %d]} {puts "Application of ELF failed"};\n', stepNum);
fprintf(INP, 'wipeAnalysis;\n');
    
end