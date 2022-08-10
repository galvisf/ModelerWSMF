%% This function creates the recorders for lateral displacement of one node 
% on each panel zone (using the nodes that have mass assigned)
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function write_DispRecorders(INP, AllNodes, isRHA)
% Nodes with structural mass (1~4 in each PZ)
node_list = AllNodes.mass(:,1); 

fprintf(INP,'###################################################################################################\n');
fprintf(INP,'#                                     DETAILED RECORDERS                                          #\n');
fprintf(INP,'###################################################################################################\n');
fprintf(INP,'\n'); 
fprintf(INP, 'if {$addBasicRecorders == 1} {\n\n');

fprintf(INP, '\t# Recorders for lateral displacement on each panel zone\n');
if isRHA
    fprintf(INP, '\trecorder Node -file $outdir/all_disp.out -dT 0.01 -time -nodes '); %-dT 0.005
else
    fprintf(INP, '\trecorder Node -file $outdir/all_disp.out -closeOnWrite -precision 16 -time -nodes '); %-dT 0.005
end

for node_i = 1:length(node_list)
    fprintf(INP, '%d ', node_list(node_i));
end
fprintf(INP,'-dof 1 disp;\n\n');

fprintf(INP, '}\n\n');

end