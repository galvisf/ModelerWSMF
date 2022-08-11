% Plot the results of a previously selected suite of ground motions
close all; clear; clc
currFolder = pwd;
font = 12;
color_specs = linspecer(7);

%% Load GM data
% First place the folder with the ground motions for all the desired
% stripes and point to it below

% Get stripe folder names
files = dir;
dirFlags = [files.isdir] & ~strcmp({files.name},'.') & ~strcmp({files.name},'..');
stripeList = extractfield(files, 'name');
stripeList = stripeList(dirFlags);

% Load ground motions for all stripes into Matlab
GM = cell(length(stripeList), 1);
GMstripe = struct;
for strIdx = 1:length(stripeList)
    cd(stripeList{strIdx})
    GMinfo = readtable('GMInfo.txt');
    dt = GMinfo.Var3;
    SF = GMinfo.Var4;
    
    gmList = GMinfo.Var2;
    for gmIdx = 1:length(gmList)
        GMstripe(gmIdx).name = gmList{gmIdx};
        aux = split(gmList{gmIdx}, '_');
        GMstripe(gmIdx).RSN  = aux{1};
        GMstripe(gmIdx).SF = SF(gmIdx);
        GMstripe(gmIdx).dt = dt(gmIdx);
        GMstripe(gmIdx).TH = load(gmList{gmIdx});
        % Remove NaNs from TH
        GMstripe(gmIdx).TH(isnan(GMstripe(gmIdx).TH)) = [];
    end
    
    GM{strIdx} = GMstripe;
    
    cd('..')
    clear GMstripe GMinfo
end

%% Compute the spectra and significant duration for each ground motion set

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T    = 0:0.10:6;
T(1) = 0.01;
zeta = 0.05;
g    = 9.81; % m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IM = struct;
for strIdx = 1:length(stripeList)
    GMstripe = GM{strIdx};
    
%%%%%% Calculate PSa and Ds575
    PSa = zeros(length(GMstripe), length(T));
    Ds575 = zeros(length(GMstripe), 1);
    
    % process each ground motion
    gmList = extractfield(GMstripe, 'name');
    for gmIdx = 1:length(gmList)
        TH = GMstripe(gmIdx).TH;
        dt = GMstripe(gmIdx).dt;
        SF = GMstripe(gmIdx).SF;
        % Compute spectra
        for i = 1:length(T)
            [PSa(gmIdx, i), ~, ~, ~, ~, ~]=L_SDOF(dt, TH, T(i), zeta);
        end
        % compute Ds5-75        
        time = (1:length(TH))*dt;
        [~,~,~,~,~,~,Ds575(gmIdx),~,~,~,~] = ...
                            StrongMotionDurations(TH,time,0,g,0);                        
    end
%%%%%%  
%%%%%% Load PSa and Ds575
%     PSa = load(['PSa_',stripeList{strIdx},'.csv']);
%     T = PSa(1, :);  
%     PSa = PSa(2:end, :);
%     Ds575 = readtable('Ds575.csv', 'ReadVariableNames', true);
%     Ds575 = Ds575.(['x',stripeList{strIdx}]);
%%%%%%

    % store data for each stripe
    IM(strIdx).PSa = PSa;
    IM(strIdx).Ds575 = Ds575;
    disp(['Done stripe ', num2str(strIdx)]) 
end

%% Save IM on CSV
% Ds575_table = table;
% for strIdx = 1:length(stripeList)
%     PSa = [T; IM(strIdx).PSa];
%     writematrix(PSa, ['PSa_',stripeList{strIdx}, '.csv'])
%     Ds575_table.(stripeList{strIdx}) = IM(strIdx).Ds575;
% end
% writetable(Ds575_table, 'Ds575.csv')

%% Plot ground motion sets
T_max_plot = max(T);
spectraMax = -1;
spectraLabel = '$Sa(T)$ [g]';
titleText = '';
isLogLog = false;
addRecords = false;

medianSpectra = table;
medianSpectra.T = T';

H = figure('position', [0, 100, 1200, 400]);
for strIdx = 1:length(stripeList) 
    PSa = IM(strIdx).PSa;
    Ds575 = IM(strIdx).Ds575;
    SF = extractfield(GM{strIdx}, 'SF');    
        
    subplot(1,2,1)
    hold on
    medianSpectra.(stripeList{strIdx}) = plotSpectraGMset(T, PSa, SF, T_max_plot, addRecords, isLogLog, spectraMax,...
        spectraLabel, titleText, font, color_specs(strIdx, :));
    
    subplot(1,2,2)
    hold on
    [f1,x1]=ecdf(Ds575);
    stairs(x1,f1,'Color', color_specs(strIdx, :),'LineWidth',2)
    xlabel('Significant duration, $Ds_{5-75}$ [s]')
    ylabel('P($Ds_{5-75} > ds_{5-75}$)')
    ylim([0, 1])
%     PlotGrayScaleForPaper(-999,'horizontal',titleText,[1 1],'normal',font)
end
legend(stripeList, 'location', 'best')
PlotGrayScaleForPaper(-999,'horizontal',titleText,[1 1],'normal',font)

writetable(medianSpectra, 'medianSpectra.csv')
figFileName = 'summaryGMsets_5rt';
savefig(H,figFileName,'compact')



% Additional seismological parameters as inputs to GMPE by Bozorgnia and Campbell 2016 for V component                        
rup.M_bar       = 7.0;      % earthquake magnitude
rup.Rjb         = 22;       % closest distance to surface projection of the fault rupture (km)
rup.Vs30        = 260;      % average shear wave velocity in the top 30m of the soil (m/s)
rup.z1          = 999;      % basin depth (km); depth from ground surface to the 1km/s shear-wave horizon,
                            % =999 if unknown
rup.region      = 1;        % =0 for global (incl. Taiwan)
                            % =1 for California
                            % =2 for Japan
                            % =3 for China or Turkey
                            % =4 for Italy
rup.Fault_Type  = 1;        % =0 for unspecified fault
                            % =1 for strike-slip fault
                            % =2 for normal fault
                            % =3 for reverse fault
[sa, sigma] = gmpe_bssa_2014(rup.M_bar, T, rup.Rjb, rup.Fault_Type, rup.region, rup.z1, rup.Vs30);





