%% This function reads results from pushover analysis
% 
% content
% 1. Get capacity curve
%
function [BaseShearCoefficient, RoofDisp] = getPushoverResults(output_dir, ...
    bldgData, plot_pushover, EQ_pattern)

storyNum = bldgData.storyNum;
storyHgt = bldgData.storyHgt;
totalWeight = sum(sum(bldgData.wgtOnBeam,2) + sum(bldgData.wgtOnCol,2) + bldgData.wgtOnEGF);

%% Get pushover results
% Get base shear
fid  = fopen([output_dir,'/baseShear.out'], 'r');
i = 1;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid); %# read line by line
        result(i,:) = sscanf(line,'%f')'; %# sscanf can read only numeric data
        i = i + 1;
    catch
        break
    end
end
fclose(fid);

baseShear = result(:,1:6:end);
baseShear = abs(sum(baseShear, 2));
baseShear = [0; baseShear];
BaseShearCoefficient = baseShear/totalWeight;

% get roof displacement
RoofDisp = zeros(length(baseShear),1);
% fid  = fopen([output_dir,'/story',num2str(storyNum),'_disp.out'], 'r');
fid  = fopen([output_dir,'/all_disp.out'], 'r');
i = 2;
while ~feof(fid)
    try % Stop if finds an issue reading the data (means analysis didn't converge)
        line = fgets(fid); %# read line by line
        temp = sscanf(line,'%f')'; %# sscanf can read only numeric data
        RoofDisp(i,1) = temp(end);
        i = i + 1;
    catch
        break
    end
end
fclose(fid);
RoofDrift = RoofDisp/sum(storyHgt)*100;

steps = min([length(BaseShearCoefficient), length(RoofDrift)]);
RoofDrift = RoofDrift(1:steps);
BaseShearCoefficient = BaseShearCoefficient(1:steps);

if plot_pushover    
    hold on
%     plot(RoofDrift, BaseShearCoefficient, 'linewidth', 2)
%     plot([0, max(RoofDrift)],base_shear_coeff_first_Mp*[1, 1], '--k')
%     xlabel('Roof drift [\%]');
    
    if BaseShearCoefficient(end) > 1
        % if last convergence is unrealistic ignore that point
        plot(RoofDrift(1:end-1), BaseShearCoefficient(1:end-1), 'linewidth', 2)
    else
        plot(RoofDrift, BaseShearCoefficient, 'linewidth', 2)
    end
    xlabel('Roof drift');
    ylabel('Base shear coefficient');
    font = 9;
    xlim([0, 10]);
    ylim([0, 0.60]);
%     legend('ASCE7 Load Pattern', 'Base shear to first Mp', 'Location', 'southoutside')
    title_text = ['Pushover curve - ', EQ_pattern];
    PlotGrayScaleForPaper(-999,'vertical',title_text,[0.5 1],'normal',font)
end

end