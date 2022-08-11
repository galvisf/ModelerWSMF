%% This function create commands for equivalent lateral load analysis
% 
% content:
% 1. write commands for pushover analysis

function pushoverAnalysis(analysisFile, modelFN, Fx_pattern, roofDrift, signPush, bldgData)

colSize = bldgData.colSize;
axisNum = bldgData.axisNum;
storyHgt = bldgData.storyHgt;

%% Create analysis file

% Name of the input file (delete existing files with same name)                   
filename = analysisFile;
if isfile(filename)
    delete(filename)
end
INP = fopen(filename,'w+');

%%%% Source main model file %%%%
fprintf(INP, 'source %s\n\n', modelFN);

%%%% Pushover inputs %%%%
fprintf(INP, '# ----- PUSHOVER INPUTS ----- #\n');
fprintf(INP, 'set sign %d\n', signPush);
fprintf(INP, 'set CtrlNode [lindex $ctrl_nodes end]\n');
fprintf(INP, 'set CtrlDOF 1\n');
fprintf(INP, 'set Dmax [expr $sign*%f*%d];	# maximum displacement of pushover\n', roofDrift, sum(storyHgt));
fprintf(INP, 'set Dincr [expr 0.005*$Dmax ];	# displacement increment\n\n');

%%%% Create load pattern %%%%
fprintf(INP, '# ----- LATERAL LOAD PATTERN ----- #\n');
fprintf(INP, 'source %s\n', [Fx_pattern,'.tcl']);

fprintf(INP, '# create load pattern for lateral pushover load coefficient when using linear load pattern\n');
fprintf(INP, 'pattern Plain 300 Linear {;			# define load pattern\n');
fprintf(INP, '\tfor {set level 2} {$level <=[expr $num_stories]} {incr level 1} {\n');
fprintf(INP, '\t\tset Fi [expr [lindex $iFi [expr $level-1]]];		# lateral load coefficient\n');
fprintf(INP, '\t\t# all force in right column (that is continuous from bottom to top)\n');
fprintf(INP, '\t\tset nodeID [lindex $ctrl_nodes $level]\n');
fprintf(INP, '\t\t# puts "$nodeID"\n');
fprintf(INP, '\t\tload $nodeID $Fi 0.0 0.0\n');
fprintf(INP, '\t}\n');
fprintf(INP, '}\n');

%%%% Write recorders for pushover analysis %%%
% Base shear (columns at the base or above basement if any)
fprintf(INP, '# ----- RECORDERS FOR ELF ----- #\n');

base_element = zeros(axisNum, 1);
text_base_element = ['recorder Element -file $outdir/baseShear.out -ele '];
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

% Displacement recorders
fprintf(INP, '# Displacement recorders #\n');
fprintf(INP, 'for {set story 1} {$story <= $num_stories} {incr story} {\n');
fprintf(INP, '\trecorder Node -file $outdir/story${story}_disp.out -time -node [lindex $ctrl_nodes $story] -dof 1 disp\n');
fprintf(INP, '}\n\n');

% % Drift recorders
% fprintf(INP, '# Drift recorders #\n');
% fprintf(INP, 'for {set story 1} {$story <= $num_stories} {incr story} {\n');
% fprintf(INP, '\trecorder Drift -file $outdir/story${story}_drift.out -iNode [lindex $ctrl_nodes [expr {$story - 1}]] -jNode [lindex $ctrl_nodes $story] -dof 1 -perpDirn 2\n');
% fprintf(INP, '}\n\n');

%% Write commands for pushover analysis
fprintf(INP, '# ----- PUSHOVER analysis commands ----- #\n');
fprintf(INP, 'source SolverPushover.tcl\n');
% fprintf(INP, 'source SolutionAlgorithm.tcl\n');   

end