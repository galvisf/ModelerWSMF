%% This function reads results from response spectrum analysis and combine using SRSS
% 
function [SDR, Cs_FirstMp, dc_ratio_beams, dc_ratio_cols, ...
          dc_ratio_spl, stress_ratio_spl, splice_relative_dc] = ...
                                    getRSAresults(output_dir, bldgData, ...
                                    secProps, Vs_ELF, spl_ratio, FyCol, addSplices)

storyNum = bldgData.storyNum;
beamSize = bldgData.beamSize;
colSize  = bldgData.colSize;
axisNum  = bldgData.axisNum;
bayNum   = bldgData.bayNum;
colSplice= bldgData.colSplice;

weigthTotal = sum(sum(bldgData.wgtOnBeam)) + sum(sum(bldgData.wgtOnCol)) + ...
    sum(bldgData.wgtOnEGF);

MnCol  = secProps.MnCol;
MnBeam = secProps.MnBeam;

tfCol = secProps.tfCol;
bfCol = secProps.bfCol;
twCol = secProps.twCol;
dbCol = secProps.dbCol;

%% Get base shear
fid  = fopen([output_dir,'/RSA_base.out'], 'r');
mode = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid); %# read line by line
        result(mode,:) = sscanf(line,'%f')'.^2; %# sscanf can read only numeric data
        mode = mode + 1;
    catch
        break
    end
end
fclose(fid);
RSA_base = result(:,1:6:end);
RSA_base = sum(sqrt(abs(sum(RSA_base, 1))));
clear result

%% Calculate amplification factor to ensure that the base shear from RSA >= ELF
ampFactor = max(1, Vs_ELF/RSA_base);

%% Get drift results
SDR = zeros(storyNum,1);
for story_i = 1:storyNum
    fid  = fopen([output_dir,'/story',num2str(story_i),'_drift.out'], 'r');
    srss = 0;
    while ~feof(fid)
        line = fgets(fid); 
        srss = srss + sscanf(line,'%f')'.^2; % read each mode, sum and square
    end
    fclose(fid);
    SDR(story_i) = sqrt(srss); % take sqrt SRSS
end
SDR = ampFactor*SDR;

%% Get element force results
fid  = fopen([output_dir,'/beam_forces.out'], 'r');
mode = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid);
        result(mode,:) = sscanf(line,'%f')'.^2; % read each mode and square
        mode = mode + 1;
    catch
        break
    end
end
fclose(fid);
% complete SRSS
M_beams_left = abs(result(:, 3:6:end));
M_beams_left = sqrt(abs(sum(M_beams_left, 1)));
M_beams_left = M_beams_left*ampFactor;

M_beams_right = abs(result(:, 6:6:end));
M_beams_right = sqrt(abs(sum(M_beams_right, 1)));
M_beams_right = M_beams_right*ampFactor;
clear result

fid  = fopen([output_dir,'/column_forces.out'], 'r');
mode = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid);
        result(mode,:) = sscanf(line,'%f')'.^2; % read each mode and square
        mode = mode + 1;
    catch
        break
    end
end
fclose(fid);
% complete SRSS
M_cols_bot = abs(result(:, 3:6:end));
M_cols_bot = sqrt(abs(sum(M_cols_bot, 1)));
M_cols_bot = M_cols_bot*ampFactor;

M_cols_top = abs(result(:, 6:6:end));
M_cols_top = sqrt(abs(sum(M_cols_top, 1)));
M_cols_top = M_cols_top*ampFactor;
clear result

%% Compute base shear for first element reaching Mp
dc_ratio_beams = zeros(size(MnBeam));
dc_ratio_beams_left = zeros(size(MnBeam));
dc_ratio_beams_right = zeros(size(MnBeam));
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
            dc_ratio_beams_left(Story, Bay) = M_beams_left(k)/MnBeam(Story, Bay);
            dc_ratio_beams_right(Story, Bay) = M_beams_right(k)/MnBeam(Story, Bay);
            dc_ratio_beams(Story, Bay) = max([M_beams_left(k), M_beams_right(k)])/MnBeam(Story, Bay);
            k = k + 1;
        end
    end
end

dc_ratio_cols = zeros(size(MnCol));
dc_ratio_cols_bot = zeros(size(MnCol));
dc_ratio_cols_top = zeros(size(MnCol));
k = 1;
for Axis = 1:axisNum
    storiesDone = zeros(storyNum, 1); % counter for columns spanning multiple stories
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
            
            dc_ratio_cols_bot(Story, Axis) = M_cols_bot(k)/MnCol(Story, Axis);
            dc_ratio_cols_top(Story, Axis) = M_cols_top(k)/MnCol(Story, Axis);
            dc_ratio_cols(Story, Axis) = max([M_cols_bot(k), M_cols_top(k)])/MnCol(Story, Axis);
            k = k + 1;
        end
    end
end

baseShearFirstMp = max(RSA_base, Vs_ELF)/max([max(dc_ratio_cols), max(dc_ratio_beams)]);
Cs_FirstMp = baseShearFirstMp/weigthTotal;

%% Get splice force results
fid  = fopen([output_dir,'/force_splice.out'], 'r');
mode = 1;
noresults_flag = 0;
if fid < 0 % no splices in model
    M_splice = 0;    
else    
    while ~feof(fid)
        try % Stop if finds an issue reading the data (means analysis didn't converge)
            line = fgets(fid);
            result(mode,:) = sscanf(line,'%f')'.^2; % read each mode and square
            mode = mode + 1;
        catch
            break
            noresults_flag = 1;
        end
    end        
    fclose(fid);
    
    if noresults_flag
        M_splice = 0;
    else
        % complete SRSS
        M_splice = sqrt(abs(sum(result, 1)));
        M_splice = M_splice*ampFactor;
        clear result
    end
end

%% Compute splice moment / columns Mp
dc_ratio_spl = zeros(size(colSplice));
stress_ratio_spl = zeros(size(colSplice));
k = 1;

if addSplices
    for Axis = 1:axisNum
        storiesDone = zeros(storyNum, 1); % counter for columns spanning multiple stories
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
                
                
                if colSplice(Story, Axis) == 1
                    % Compute demand capacity assuming full welding
                    dc_ratio_spl(Story, Axis) = M_splice(k)/MnCol(Story, Axis);
                    
                    % Compute flange weld sress
                    if strcmp(colSize{Floor_j-1, Axis}(1:3), 'BOX')
                        twCol(Story, Axis) = 2*twCol(Story, Axis); % to consider both webs
                    end
                    
                    Ispl = 2*1/12*bfCol(Story, Axis)*(tfCol(Story, Axis)*spl_ratio)^3 + ...
                        2*bfCol(Story, Axis)*(tfCol(Story, Axis)*spl_ratio)*(dbCol(Story, Axis)/2 - tfCol(Story, Axis)*spl_ratio/2)^2 + ...
                        1/12*twCol(Story, Axis)*spl_ratio*(0.7*(dbCol(Story, Axis)-4*tfCol(Story, Axis)))^3;
                    c = dbCol(Story, Axis)/2;
                    stress_ratio_spl(Story, Axis) = M_splice(k)*c/Ispl;
                    
                    k = k + 1;
                end
                
            end
        end
    end
    stress_ratio_spl = stress_ratio_spl/FyCol;
end

%% Compare splice stress ratio with adjacent beams and columns
% Get critical D/C ratio per connection
dc_critical_bot = zeros(size(colSplice));
dc_critical_top = zeros(size(colSplice));

for Axis = 1:axisNum
    for Story = 1:storyNum
        if colSplice(Story, Axis) ~= 0
            
            
            if Axis == 1
                if Story == 1
                    dc_critical_bot(Story, Axis) = dc_ratio_cols_bot(Story, Axis);
                else
                    dc_critical_bot(Story, Axis) = max([dc_ratio_cols_bot(Story, Axis), ...
                                           dc_ratio_cols_top(Story-1, Axis), ...
                                           dc_ratio_beams_left(Story-1, Axis)]);
                end
            elseif Axis == axisNum
                if Story == 1
                    dc_critical_bot(Story, Axis) = dc_ratio_cols_bot(Story, Axis);
                else
                    dc_critical_bot(Story, Axis) = max([dc_ratio_cols_bot(Story, Axis), ...
                                           dc_ratio_cols_top(Story-1, Axis), ...
                                           dc_ratio_beams_right(Story-1, Axis-1)]);
                end
            else
                if Story == 1
                    dc_critical_bot(Story, Axis) = dc_ratio_cols_bot(Story, Axis);
                else
                    dc_critical_bot(Story, Axis) = max([dc_ratio_cols_bot(Story, Axis), ...
                                       dc_ratio_cols_top(Story-1, Axis), ...
                                       dc_ratio_beams_left(Story-1, Axis-1), ...
                                       dc_ratio_beams_right(Story-1, Axis)]);
                end
            end
            if Axis == 1
                if Story == storyNum
                    dc_critical_top(Story, Axis) = max([dc_ratio_cols_top(Story, Axis), ...
                                       dc_ratio_beams_left(Story, Axis)]);
                else
                    dc_critical_top(Story, Axis) = max([dc_ratio_cols_top(Story, Axis), ...
                                           dc_ratio_cols_bot(Story+1, Axis), ...
                                           dc_ratio_beams_left(Story, Axis)]);
                end
            elseif Axis == axisNum
                if Story == storyNum 
                    dc_critical_top(Story, Axis) = max([dc_ratio_cols_top(Story, Axis), ...
                                           dc_ratio_beams_right(Story, Axis-1)]);  
                else
                    dc_critical_top(Story, Axis) = max([dc_ratio_cols_top(Story, Axis), ...
                                            dc_ratio_cols_bot(Story+1, Axis), ...
                                            dc_ratio_beams_right(Story, Axis-1)]);
                end
            else
                if Story == storyNum
                    dc_critical_top(Story, Axis) = max([dc_ratio_cols_top(Story, Axis), ...
                                           dc_ratio_beams_left(Story, Axis-1), ...
                                           dc_ratio_beams_right(Story, Axis)]);       
                else
                    dc_critical_top(Story, Axis) = max([dc_ratio_cols_top(Story, Axis), ...
                                           dc_ratio_cols_bot(Story+1, Axis), ...
                                           dc_ratio_beams_left(Story, Axis-1), ...
                                           dc_ratio_beams_right(Story, Axis)]);                    
                end
            end
        end        
    end
end
dc_critical = max(dc_critical_top, dc_critical_bot);
splice_relative_dc = stress_ratio_spl - dc_critical;


fclose all;
end