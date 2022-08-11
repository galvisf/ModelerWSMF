% AT2_to_TH reads and process the ground motions in AT2 format hosted in the "folder"
% with filenames listed in AT2_filenmaes
% 
% INPUTS
%   folder        = path to the folder with the AT2 files
%   AT2_filenames = cell array with the names of the AT2 files
%
% OUTPUTS
%   GM            = structure with all the time histories and dt
% 
function GM = AT2_to_TH(folder, AT2_filenames)

    for i=1:length(AT2_filenames)
        A = dlmread([folder, '\', AT2_filenames{i}],'',4,0);
        GM(i).TH = reshape(A',size(A,1)*size(A,2),1);
        GM(i).dt = 0.02;
    end
    for i=1:length(AT2_filenames)
        B{i} = fileread([folder, '\', AT2_filenames{i}]);
        B{i}(strfind(B{i}, '=')) = []; %Drops equal symbols
        Key   = 'DT'; %Looks for DT
        Index = strfind(B{i}, Key); %Find location of Key
        Value = sscanf(B{i}(Index(1) + length(Key):end), '%g', 1); %Get the value next to Key
        GM(i).dt = Value;
    end

end