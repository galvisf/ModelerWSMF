%% This function creates header, starting commands, and general inputs
% for the model
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
%
function [backbone, degradation, connType, addEGF] = write_OpenArguments(INP, ...
                        bldgData, composite, fractureElement, ...
                        addEGF, addSplices, rigidFloor, generation, ...
                        connType, backbone, degradation, panelZoneModel)
                        
%% Read relevant variables
storyNum = bldgData.storyNum;
webConnection = bldgData.webConnection.Type{1};

%%
% HEADER LINES
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'#                                        %d-story MRF Building\n',storyNum);
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'####################################################################################################\n');
fprintf(INP,'\n');

% Verify a valid beam model
% if fractureElement && strcmp(generation, 'Pre_Northridge') && ~strcmp(backbone, 'NIST2017')
%     disp('backbone=NIST2017 -> fracture in fiber section')
%     backbone = 'NIST2017';
% end
if ~fractureElement && strcmp(generation, 'Pre_Northridge')
    disp('connType=PN to consider fracture in the backbone')
    connType = 'PN';
    if degradation
        disp('degradation=False -> no cyclic degradation in pre-Northridge')
        degradation = false;
    end
end
if strcmp(backbone, 'ASCE41') && degradation
    disp('degradation=False -> no cyclic degradation in ASCE41 backbones')
    degradation = false;
end
% if strcmp(backbone, 'Elastic') && addEGF
%     disp('Use leaning column for gravity system model')
%     addEGF = false;
% end

fprintf(INP,'####### MODEL FEATURES #######;\n');
    fprintf(INP,'# UNITS:                     kip, in\n');
    fprintf(INP,'# Generation:                %s\n', generation);
if composite
    fprintf(INP,'# Composite beams:           True\n');
else
    fprintf(INP,'# Composite beams:           False\n');
end
if fractureElement
    fprintf(INP,'# Fracturing fiber sections: True\n');
else
    fprintf(INP,'# Fracturing fiber sections: False\n');
end
if addEGF
    fprintf(INP,'# Gravity system stiffness:  True\n');
else
    fprintf(INP,'# Gravity system stiffness:  False\n');
end
if addSplices
    fprintf(INP,'# Column splices included:   True\n');
else
    fprintf(INP,'# Column splices included:   False\n');
end
if rigidFloor
    fprintf(INP,'# Rigid diaphragm:           True\n');
else
    fprintf(INP,'# Rigid diaphragm:           False\n');
end
fprintf(INP,'# Plastic hinge type:        %s\n', connType);
fprintf(INP,'# Backbone type:             %s\n', backbone);
if degradation
    fprintf(INP,'# Cyclic degradation:        True\n');
else
    fprintf(INP,'# Cyclic degradation:        False\n');
end
fprintf(INP,'# Web connection type:       %s\n', webConnection);
fprintf(INP,'# Panel zone model:          %s\n', panelZoneModel);
fprintf(INP,'\n');

% fprintf(INP,'# CLEAR ALL;\n');
% fprintf(INP,'wipe all;\n');
% fprintf(INP,'\n');

fprintf(INP,'# BUILD MODEL (2D - 3 DOF/node)\n');
fprintf(INP,'wipe all\n');
fprintf(INP,'model basic -ndm 2 -ndf 3\n');
fprintf(INP,'\n');

end
