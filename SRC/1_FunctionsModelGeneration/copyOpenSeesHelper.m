%% This function clones all the tcl files necesary to run a WSMF model in a new folder
%
% Original from: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function copyOpenSeesHelper(sourceFolder, destinationFolder, isPushover)

[~, ~, ~] = copyfile([sourceFolder,'\ConstructPanel_Cross.tcl'], [destinationFolder,'\ConstructPanel_Cross.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\ConstructPanel_Rectangle.tcl'], [destinationFolder,'\ConstructPanel_Rectangle.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\fracSectionBolted.tcl'], [destinationFolder,'\fracSectionBolted.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\fracSectionWelded.tcl'], [destinationFolder,'\fracSectionWelded.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\fracSectionSplice.tcl'], [destinationFolder,'\fracSectionSplice.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\hingeBeamColumn.tcl'], [destinationFolder,'\hingeBeamColumn.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\hingeBeamColumnFracture.tcl'], [destinationFolder,'\hingeBeamColumnFracture.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\hingeBeamColumnSpliceZLS.tcl'], [destinationFolder,'\hingeBeamColumnSpliceZLS.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\elasticBeamColumnSplice.tcl'], [destinationFolder,'\elasticBeamColumnSplice.tcl']);
% [~, ~, ~] = copyfile([sourceFolder,'\hingeBeamColumnSplice.tcl'], [destinationFolder,'\hingeBeamColumnSplice.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\matBilin02.tcl'], [destinationFolder,'\matBilin02.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\matIMKBilin.tcl'], [destinationFolder,'\matIMKBilin.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\matHysteretic.tcl'], [destinationFolder,'\matHysteretic.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\matSplice.tcl'], [destinationFolder,'\matSplice.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\modalAnalysis.tcl'], [destinationFolder,'\modalAnalysis.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\sigCrNIST2017.tcl'], [destinationFolder,'\sigCrNIST2017.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\PanelZoneSpring.tcl'], [destinationFolder,'\PanelZoneSpring.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\SolverNewmark.tcl'], [destinationFolder,'\SolverNewmark.tcl']);
[~, ~, ~] = copyfile([sourceFolder,'\Spring_Pinching.tcl'], [destinationFolder,'\Spring_Pinching.tcl']);

if isPushover
    [~, ~, ~] = copyfile([sourceFolder,'\SolverPushover.tcl'], [destinationFolder,'\SolverPushover.tcl']);    
end

end