%% This function reads dinamic properties from modal analysis
% 

function  [T, mass_part] = getModalResults(bldgData, AllNodes, AllEle, ...
    output_dir, numModes, scale, font, plot_loc)
storyNum  = bldgData.storyNum;
floorNum  = bldgData.floorNum;

%% Get modal results
% read file
fid  = fopen([output_dir,'/modal_results.txt'], 'r');

eigen_values = zeros(numModes, 5);
mass_part = zeros(numModes, 4);
i = 1;
j = 1;
while ~feof(fid)
    try
        line = fgets(fid); %# read line by line
        eigen_values(i,:) = sscanf(line,'%f')';
        i = i + 1;
    catch
        try
            mass_part(j,:) = sscanf(line,'%f')';
            j = j + 1;
        end
    end
end
fclose(fid);

T = eigen_values(:,5)';
mass_part = mass_part(1:numModes,2)';

%% Get and plot mode shapes
% read file
fid  = fopen([output_dir,'/mode_shapes.txt'], 'r');

mode_shapes = zeros(storyNum, numModes);
j = 0;
while ~feof(fid)
    try
        line = fgets(fid); % read line by line
        mode_shapes(i,j) = sscanf(line,'%f')';
        i = i + 1;
    catch
        i = 1;
        j = j + 1;
    end
end
fclose(fid);

% Plot mode shapes
for mode_i = 1:3
    title_text = {['Mode ',num2str(mode_i)],['Period = ',num2str(T(mode_i),'%0.2f'), 's'], ...
                  ['Participation = ',num2str(mass_part(mode_i),'%.f'),'\%']};
    
    if plot_loc == 999          
        subplot(3,4,mode_i+1)
    else        
        subplot(7,4,mode_i+1+plot_loc)
    end
    hold on
    plot_nodes = false;
    plot_gravity = false;
    disp = zeros(floorNum,1);
    plotFrame(AllNodes, AllEle, disp, plot_nodes, plot_gravity, [1,1,1]*0.8, '', font)
    disp = [0; mode_shapes(:,mode_i)/max(abs(mode_shapes(:,mode_i)))*scale];
    plotFrame(AllNodes, AllEle, disp, plot_nodes, plot_gravity, [0,0,0], title_text, font)
end

end