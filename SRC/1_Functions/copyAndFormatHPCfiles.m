%% This function clones all the tcl files necesary to run a MSA on a HPC
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function copyAndFormatHPCfiles(sourceFolder, destinationFolder, ...
                                modelFilename, gmSetPath, gmSetName, ...
                                nGMPerSet, colDriftLimit, runHours)

% Run MSA Parallel script
text = readlines([sourceFolder,'/RunMSAParallel.tcl']);
text = strrep(text, '##gmSetName##', gmSetName);
text = strrep(text, '##gmSetPath##', gmSetPath);
text = strrep(text, '##nGMPerSet##', num2str(nGMPerSet));
text = strrep(text, '##colDriftLimit##', num2str(colDriftLimit));
text = strrep(text, '##modelFilename##', modelFilename);
fclose all;

fileID = fopen([destinationFolder,'\RunMSAParallel.tcl'],'w');
for i = 1:length(text)
    fprintf(fileID, text(i));
    fprintf(fileID, '\n');
end
fclose(fileID);

% Run MSA.batch
text = readlines([sourceFolder,'/MSA.sbatch']);
text = strrep(text, '##runName##', modelFilename(1:end-4));
text = strrep(text, '##runHours##', num2str(runHours));
fclose all;

fileID = fopen([destinationFolder,'\MSA.sbatch'],'w');
for i = 1:length(text)
    fprintf(fileID, text(i));
    fprintf(fileID, '\n');
end
fclose(fileID);

% Additional helper functions
[~, ~, ~] = copyfile([sourceFolder,'/DriftCheck.tcl'], [destinationFolder,'/DriftCheck.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'/RecorderAnalysisMSA.tcl'], [destinationFolder,'/RecorderAnalysisMSA.tcl']);

end