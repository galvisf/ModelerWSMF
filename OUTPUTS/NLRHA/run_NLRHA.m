clear
close all
clc
font = 9;

%% Frame props
modelName = 'Frame1C_Grid16_1.tcl';

%% Run NLRHA
for gm_i = 1:11
    %% GM
    GM = readtable('GroundMotion/GMInfo.txt');
    record_filename = GM.Var2{gm_i};
    dt = GM.Var3(gm_i);
    SF = GM.Var4(gm_i);
    numpts = GM.Var5(gm_i);
    TH = load(['GroundMotion/', record_filename]);

    %% Convergence parameters
    tol = 1e-6;
    subSteps = 2;
    dtRecord = 0.005; % for recorders

    %% Modify OS model to run correct GM
    modelFN = ['modelBuild_',num2str(gm_i),'.tcl'];
    [~, ~, ~] = copyfile('ModelBuild_RHA_template.tcl', modelFN);

    % read file
    fid = fopen(modelFN, 'r+');
    f = fread(fid, '*char')';
    fclose(fid); 

    % update placeholders
    f = strrep(f, '##GM_NAME##', record_filename);
    f = strrep(f, '##modelName##', modelName);
    f = strrep(f, '##GroundMotionFolderPath##', 'GroundMotion');
    f = strrep(f, '##SF##', num2str(SF));
    f = strrep(f, '##dt##', num2str(dt));
    f = strrep(f, '##numpts##', num2str(numpts));

    % write file
    fid  = fopen(modelFN, 'w+');
    fprintf(fid,'%s',f);
    fclose(fid);

    %% Run OS Model for a given GM
    % Run model
    cmd = sprintf(['OpenSees_3_0 ',modelFN]);
    tic
    system(cmd);
    toc
end