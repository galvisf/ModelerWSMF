%% This function loads helper functions in the OpenSees tcl file
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function write_SourceSubroutine(INP,backbone,panelZoneModel,fractureElement,...
                    addSplices,addEGF)

fprintf(INP,'####################################################################################################\n');
fprintf(INP,'#                                      SOURCING HELPER FUNCTIONS                                   #\n');
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'\n');

if strcmp(panelZoneModel,'None')
    fprintf(INP,'source ConstructPanel_Cross.tcl;\n');
else
    fprintf(INP,'source ConstructPanel_Rectangle.tcl;\n');
    fprintf(INP,'source PanelZoneSpring.tcl;\n');
end
if fractureElement
    fprintf(INP,'source fracSectionBolted.tcl;\n');
    fprintf(INP,'source hingeBeamColumnFracture.tcl;\n');    
    fprintf(INP,'source sigCrNIST2017.tcl;\n');
end
if fractureElement || addSplices
    fprintf(INP,'source fracSectionWelded.tcl;\n');    
end
if addSplices
    fprintf(INP,'source fracSectionSplice.tcl;\n');
    if strcmp(backbone, 'Elastic')
        fprintf(INP,'source elasticBeamColumnSplice.tcl;\n');
    else
        fprintf(INP,'source hingeBeamColumnSpliceZLS.tcl;\n');
        fprintf(INP,'source matSplice.tcl;\n');        
    end
end
fprintf(INP,'source hingeBeamColumn.tcl;\n');
fprintf(INP,'source matHysteretic.tcl;\n');
if ~strcmp(backbone, 'Elastic')
    fprintf(INP,'source matIMKBilin.tcl;\n');
    fprintf(INP,'source matBilin02.tcl;\n');
end
if addEGF
    fprintf(INP,'source Spring_Pinching.tcl;\n');
end
fprintf(INP,'source modalAnalysis.tcl;\n');
% fprintf(INP,'source SolverNewmark.tcl;\n');

fprintf(INP,'\n');
end