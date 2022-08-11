% Format selected records for running RHA in Sherlock HPC resources
clear; close all; clc
currFolder = pwd;

%% INPUTS
setNames = {'UHS_72yrs_ClassD', 'UHS_475yrs_ClassD', 'UHS_2475yrs_ClassD'};
results_directory = 'SanFrancisco_UHS_VS30259';
frameDir = 'Y'; % X  Y
mkdir(results_directory)

%% Format ground motion sets

for set = setNames
    % Read table of selected set
    searchResults = readtable([set{1}, '\selectedRecords.xlsx']);
    
    % Get component filenames
    if strcmp(frameDir, 'X')
        gmsname = searchResults.Horizontal_1Acc_Filename;
    else
        gmsname = searchResults.Horizontal_2Acc_Filename;
    end
    gmsnum = length(gmsname);       

    % Retrive SF for each ground motion
    SFforSet = searchResults.ScaleFactor;

    % Get dt and Acc
    GM = AT2_to_TH(set{1}, gmsname);

    % create forder for each stripe
    stripeFileName = [results_directory,'/',set{1},'_',frameDir];
    mkdir(stripeFileName)
    cd(stripeFileName)

    % Create ground motion folder for current stripe
    GMinfo = cell(gmsnum, 4);
    for gmIdx = 1:gmsnum        
        gmFileName = gmsname{gmIdx};            

        % Create each ground motion file
        newfile = fopen(gmFileName,'w');
                 fprintf(newfile,'%2.5f\n',GM(gmIdx).TH);
        fclose(newfile);

        % Save properties of each ground motion
        GMinfo{gmIdx,1} = gmIdx;        
        GMinfo{gmIdx,2} = gmFileName;               
        GMinfo{gmIdx,3} = GM(gmIdx).dt;        
        GMinfo{gmIdx,4} = SFforSet(gmIdx);
    end
    fileID = fopen('GMInfo.txt','w');
    for gmIdx = 1:gmsnum  
        fprintf(fileID,'%1.0f\t%s\t%1.3f\t%1.3f \n',GMinfo{gmIdx,:});
    end
    fclose(fileID);

    cd(currFolder)

        % Plot scaled set spectra for current stripe
%         if plotScaledSet
%             ScaledOrNot = true;
%             T_max_plot = 10;
%             PS_max = 3;
%             Sv_max = 6;
%             Sd_max = 3.5;
%             font = 9;
%             plotGMsetGMSpectra([1 1]*config.T1,[0 PS_max],gmpool_IM,gmTag,...
%                 ScaledOrNot,SFforSet,T_max_plot,PS_max,Sv_max,...
%                 Sd_max,font,[num2str(rp), 'yrs'])
%         end
    
end