%% This function reads results from equivalent lateral force analysis
% 
function [SDR, Cs_FirstMp, dc_ratio_beams, dc_ratio_cols] = ...
                                    getELFPresults(output_dir, bldgData, ...
                                    secProps)

storyNum = bldgData.storyNum;
beamSize = bldgData.beamSize;
colSize  = bldgData.colSize;
axisNum  = bldgData.axisNum;
bayNum   = bldgData.bayNum;

weigthTotal = sum(sum(bldgData.wgtOnBeam)) + sum(sum(bldgData.wgtOnCol)) + ...
    sum(bldgData.wgtOnEGF);


MnCol  = secProps.MnCol;
MnBeam = secProps.MnBeam;

%% Get drift results
SDR = zeros(storyNum,1);
for story_i = 1:storyNum
    fid  = fopen([output_dir,'/story',num2str(story_i),'_drift_env.out'], 'r');
    while ~feof(fid)
        line = fgets(fid); %# read line by line
    end
    fclose(fid);
    SDR(story_i) = sscanf(line,'%f')'; %# sscanf can read only numeric data
end

%% Get element force results
fid  = fopen([output_dir,'/beam_forces.out'], 'r');
Story = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid); %# read line by line
        result(Story,:) = sscanf(line,'%f')'; %# sscanf can read only numeric data
        Story = Story + 1;
    catch
        break
    end
end
fclose(fid);
M_beams_left = abs(result(end, 3:6:end));
M_beams_right = abs(result(end, 6:6:end));
clear result

fid  = fopen([output_dir,'/column_forces.out'], 'r');
Story = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid); %# read line by line
        result(Story,:) = sscanf(line,'%f')'; %# sscanf can read only numeric data
        Story = Story + 1;
    catch
        break
    end
end
fclose(fid);
M_cols_bot = abs(result(end, 3:6:end));
M_cols_top = abs(result(end, 6:6:end));
clear result

%% Get base shear
fid  = fopen([output_dir,'/EPL_base.out'], 'r');
Story = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid); %# read line by line
        result(Story,:) = sscanf(line,'%f')'; %# sscanf can read only numeric data
        Story = Story + 1;
    catch
        break
    end
end
fclose(fid);

EPL_base = result(:,1:6:end);
EPL_base = abs(sum(EPL_base(end,:), 2));

%% Compute base shear for first element reaching Mp
dc_ratio_beams = zeros(size(MnBeam));
k = 1;
for Story = 1:storyNum % loop for all elements in given story first since that is the order of the recorder
    baysDone = zeros(bayNum, 0); % counter for beams spanning multiple bays
    for Bay = 1:bayNum
        if ~isempty(beamSize{Story, Bay}) && ~ismember(Bay, baysDone)
            % Bay left end
            Axis_i = Bay;
            
            % Find axis for right end (in case of missing columns, beam spans multiple bays)
            Axis_j = 0;
            i = 0;
            while Axis_j == 0
                if ~isempty(colSize{Story, min(Bay+i+1, axisNum)}) &&  ...
                        ~isempty(colSize{min(Story+1, storyNum), min(Bay+i+1, axisNum)})
                    Axis_j = Bay+i+1;
                else
                    i = i + 1;
                end
            end
            baysDone(Axis_i:Axis_j-1) = Axis_i:Axis_j-1;
            
            dc_ratio_beams(Story, Bay) = max([M_beams_left(k), M_beams_right(k)])/MnBeam(Story, Bay);
            k = k + 1;
        end
    end
end

dc_ratio_cols = zeros(size(MnCol));
k = 1;
for Axis = 1:axisNum
    storiesDone = zeros(storyNum, 0); % counter for columns spanning multiple stories
    for Story = 1:storyNum
        if ~isempty(colSize{Story, Axis}) && ~ismember(Story, storiesDone)
            % Floor bottom end
            Floor_i = Story;
            
            % Find Floor for top end (in case of missing beams the column spans multiple stories)
            Floor_j = 0;
            i = 0;
            while Floor_j == 0
                if ~isempty(beamSize{Story+i, max(Axis-1,1)}) || ~isempty(beamSize{Story+i, min(Axis,bayNum)})
                    Floor_j = Story+i+1;
                else
                    i = i + 1;
                end
            end
            storiesDone(Floor_i:Floor_j-1) = Floor_i:Floor_j-1;
            
            dc_ratio_cols(Story, Axis) = max([M_cols_bot(k), M_cols_top(k)])/MnCol(Story, Axis);
            k = k + 1;
        end
    end
end

baseShearFirstMp = EPL_base/max([max(dc_ratio_cols), max(dc_ratio_beams)]);
Cs_FirstMp = baseShearFirstMp/weigthTotal;

fclose all;
end