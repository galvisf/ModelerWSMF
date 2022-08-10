%% This function writes the EGF springs for beams and columns
%
% Original from: Prof. Ahmed Elkady
% Adapted by: Francisco A. Galvis
% John A. Blume Earthquake engineering center
% Stanford University
% 
function write_EGFsprings (INP,bldgData,AISC_v14p1,addEGF,Composite,FyBeam,backbone)
%% Read relevant variables
storyNum    = bldgData.storyNum;
axisNum     = bldgData.axisNum;
frameType   = bldgData.frameType;
nGB         = bldgData.nGB;
beamSizeEGF = bldgData.beamSizeEGF;

%%
if addEGF && strcmp(frameType, 'Perimeter')
    %% Create EGF springs    
    fprintf(INP,'# GRAVITY BEAMS SPRINGS\n');    
    if Composite==1
        ResponseID =1;
    else
        ResponseID =0;
    end
                  
    % Write beam springs    
    for Floor=2:storyNum+1                       
                
        if strcmp(backbone, 'Elastic')
            nodeID0=10000*Floor+100*(axisNum+1);
            nodeID1=10000*Floor+100*(axisNum+1)+04;
            fprintf(INP,'equalDOF %7d %7d 1 2 3;',nodeID0,nodeID1);

            nodeID0=10000*Floor+100*(axisNum+2);
            nodeID1=10000*Floor+100*(axisNum+2)+02;
            fprintf(INP,'equalDOF %7d %7d 1 2 3;',nodeID0,nodeID1);
        else
            % Get beam properties
            Section=beamSizeEGF(Floor-1);
            props = getSteelSectionProps(Section, AISC_v14p1);  

            % Compute spring properties
            Z_GB = nGB(Floor-1) * props.Zz;
            My_GB =	1.1 * FyBeam * Z_GB;
            SpringID_R=9000000+Floor*10000+(axisNum+1)*100+04;
            SpringID_L=9000000+Floor*10000+(axisNum+2)*100+02; 
        
            % Write spring to file
            nodeID0=10000*Floor+100*(axisNum+1);
            nodeID1=10000*Floor+100*(axisNum+1)+04;
            fprintf(INP,'Spring_Pinching  %7d %7d %7d %.4f $gap %d; ',SpringID_R,nodeID0,nodeID1,My_GB,ResponseID);

            nodeID0=10000*Floor+100*(axisNum+2);
            nodeID1=10000*Floor+100*(axisNum+2)+02;
            fprintf(INP,'Spring_Pinching  %7d %7d %7d %.4f $gap %d; ',SpringID_L,nodeID0,nodeID1,My_GB,ResponseID);          
        end
        fprintf(INP,'\n');
    end
    fprintf(INP,'\n');
end
end