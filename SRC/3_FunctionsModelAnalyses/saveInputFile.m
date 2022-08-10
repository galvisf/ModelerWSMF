% saveInputFile creates an .xlxs file with all the information of each
% frame properly formated for OpenSees model generation.
% 
function saveInputFile(resultFolderName,geomFN,basicInfo,bayLength,...
                        storyHeight,colArray,colOrientations,beamArray,...
                        colSplice,DoublerPlates,nColEGF,nColMRForthogonal,...
                        nBeamsEGF,colSizeEGF,beamSizeEGF, wgtOnBeam,...
                        wgtOnCol,EGFweigth,webConnection)
                  
% Name of the input file (delete existing files with same name)                   
if isempty(resultFolderName)
    filename = geomFN;
else
    filename = [resultFolderName,'\',geomFN];
end
if isfile(filename)
    delete(filename)
end

% Basic data tab
writetable(struct2table(basicInfo),filename,'Sheet','basics');

% Bay length tab
bayName = cell(length(bayLength),1);
for i = 1:length(bayLength)
    bayName{i} = ['Bay',num2str(i)];
end
bayLength = bayLength';
bayTable = table(bayName,bayLength);
writetable(bayTable,filename,'Sheet','bayLgth');

% Story height tab
storyName = cell(length(storyHeight),1);
for i = 1:length(storyHeight)
    storyName{i} = ['story',num2str(i)];
end
storyTable = table(storyName,storyHeight);
writetable(storyTable,filename,'Sheet','storyHgt');

% Column sizes tab
axisName = cell(1,length(bayLength)+2);
for i = 2:length(axisName)
    axisName{i} = ['Axis',num2str(i-1)];
end
colArray = [storyName,colArray];
colArray = [axisName;colArray];
writecell(colArray,filename,'Sheet','colSize');

% Column orientation tab
colOrientations = num2cell(colOrientations);
axisName = cell(1,length(bayLength)+2);
for i = 2:length(axisName)
    axisName{i} = ['Axis',num2str(i-1)];
end
colOrientations = [storyName,colOrientations];
colOrientations = [axisName;colOrientations];
writecell(colOrientations,filename,'Sheet','colOrientations');

% Beam sizes tab
bayName = cell(1,length(bayLength)+1);
for i = 2:length(bayName)
    bayName{i} = ['Bay',num2str(i-1)];
end
floorName = cell(length(storyHeight),1);
for i = 1:length(floorName)
    floorName{i} = ['Floor',num2str(i+1)];
end
beamArray = [floorName,beamArray];
beamArray = [bayName;beamArray];
writecell(beamArray,filename,'Sheet','beamSize');

% Column splice tab
colSplice = num2cell(colSplice);
colSplice = [storyName,colSplice];
colSplice = [axisName;colSplice];
writecell(colSplice,filename,'Sheet','colSplice');

% Doubler plates tab
DoublerPlates = num2cell(DoublerPlates);
DoublerPlates = [floorName,DoublerPlates];
DoublerPlates = [axisName;DoublerPlates];
writecell(DoublerPlates,filename,'Sheet','DoublerPlates');

% Columns from EGF tab
nColEGFtable = table(storyName, nColEGF, colSizeEGF, nColMRForthogonal);
writetable(nColEGFtable,filename,'Sheet','nColEGF');

% Beams from EGF tab
nColEGFtable = table(floorName, nBeamsEGF, beamSizeEGF);
writetable(nColEGFtable,filename,'Sheet','nBeamsEGF');

% Weight on beams of the MRF tab
wgtOnBeam = num2cell(wgtOnBeam);
wgtOnBeam = [floorName,wgtOnBeam];
wgtOnBeam = [bayName;wgtOnBeam];
writecell(wgtOnBeam,filename,'Sheet','wgtOnBeam');

% Weight on columns of the MRF tab
wgtOnCol = num2cell(wgtOnCol);
wgtOnCol = [floorName,wgtOnCol];
wgtOnCol = [axisName;wgtOnCol];
writecell(wgtOnCol,filename,'Sheet','wgtOnCol');

% Weight on the EGF tab
wgtOnEGF = table(floorName, EGFweigth);
writetable(wgtOnEGF,filename,'Sheet','wgtOnEGF');

% Web connection details per beam tab
writetable(struct2table(webConnection),filename,'Sheet','webConnection');

end