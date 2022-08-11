% Ground motion selection
clear; close all; clc;
currFolder = pwd;

font = 12;

%% Inputs
T_tg = 0:0.01:5;
D = 0.05;

%% Target
Ss = 1.22;
S1 = 0.6934;
TL = 8;
[Sa_tg] = DE_NEHRP(Ss, S1, TL, T_tg);

%% Selected records
filenames = {'RSN6_IMPVALL.I_I-ELC180.AT2',
    'RSN9_BORREGO_B-ELC000.AT2',
    'RSN15_KERN_TAF021.AT2',
    'RSN28_PARKF_C12050.AT2',
    'RSN40_BORREGO_A-SON033.AT2',
    'RSN54_SFERN_BSF135.AT2',
    'RSN55_SFERN_BVP090.AT2',
    'RSN59_SFERN_CSM095.AT2',
    'RSN67_SFERN_ISD014.AT2',
    'RSN86_SFERN_SON033.AT2',
    'RSN96_MANAGUA_B-ESO090.AT2'};
SF = [2.0225
    9.831
    4.1626
    9.3442
    16.3957
    62.9572
    49.3358
    35.3724
    86.5871
    35.9024
    2.7443
    ];

% Format
folder = 'Records';
GM = AT2_to_TH(folder, filenames);
gmsnum = length(filenames);

% Compute spectra
for gm_i = 1:gmsnum
    for T_i = 1:length(T_tg)
        [~, ~, ~, ~, GM(gm_i).PSa(T_i), ~, ~]= L_SDOF(GM(gm_i).dt, GM(gm_i).TH, T_tg(T_i), D);
    end
end
spectraName = 'PSa';
[PS_mean, PS_median] = computeMeansGMset(GM,SF,spectraName);

%% Plot spectra
T_max_plot = max(T_tg);
PS_max = 2;
spectraLabel = '$S_a(T)$ [g]';
spectraName = 'PSa';
titleText = '';
plotSpectraGMset(T_tg,GM,SF,T_max_plot,PS_max,PS_mean,-PS_median,spectraName,spectraLabel,titleText,font)
plot(T_tg,Sa_tg,'LineWidth',2,'Color','r')
legend({'Mean set', 'ASCE 41 BSE-2E'})

%% Save ground motions in intuitive format
mkdir('GroundMotion')

cd('GroundMotion')
% Create ground motion folder for current stripe
GMinfo = cell(gmsnum, 4);
for gmIdx = 1:gmsnum        
    gmFileName = filenames{gmIdx};           

    % Create each ground motion file
    newfile = fopen(gmFileName,'w');
             fprintf(newfile,'%2.5f\n',GM(gmIdx).TH);
    fclose(newfile);

    % Save properties of each ground motion
    GMinfo{gmIdx,1} = gmIdx;        
    GMinfo{gmIdx,2} = gmFileName;               
    GMinfo{gmIdx,3} = GM(gmIdx).dt;        
    GMinfo{gmIdx,4} = SF(gmIdx);
    GMinfo{gmIdx,5} = length(GM(gmIdx).TH);
end
fileID = fopen('GMInfo.txt','w');
for gmIdx = 1:gmsnum  
    fprintf(fileID,'%1.0f\t%s\t%1.3f\t%1.3f\t%d \n',GMinfo{gmIdx,:});
end
fclose(fileID);
