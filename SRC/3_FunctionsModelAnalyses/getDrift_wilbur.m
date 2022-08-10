function SDR = getDrift_wilbur(bldgData, secProps, Lcol, Es, Fx)

%% Read relevant variables 
bayNum   = bldgData.bayNum;
floorNum = bldgData.floorNum;
storyHgt = bldgData.storyHgt;
bayLgth  = bldgData.bayLgth;

ICol   = secProps.ICol;
IzBeam = secProps.IzBeam;

%% Drift check using Wilbur method
% Stiffness of each story
R = zeros(floorNum - 1, 1);

lengthBeam = zeros(floorNum-1, bayNum);
for i = 2:floorNum
    for j = 1:bayNum        
        lengthBeam(i-1, j) = bayLgth(j);
    end
end

Kc = ICol./Lcol;
Kb = IzBeam./lengthBeam;
R(1) = 48*Es/(storyHgt(1)*(4*storyHgt(1)/sum(Kc(1,:)) + ...
    (storyHgt(1)+storyHgt(2))/(sum(Kb(1,:)) + sum(Kc(1,:))/12)));
R(2) = 48*Es/(storyHgt(2)*(4*storyHgt(2)/sum(Kc(2,:)) + ...
    (storyHgt(1)+storyHgt(2))/(sum(Kb(1,:)) + sum(Kc(1,:))/12) + ...
    (storyHgt(2)+storyHgt(3))/(sum(Kb(2,:)))));
for n = 3:floorNum - 2
    m = n - 1;
    o = n + 1;
    R(n) = 48*Es/(storyHgt(n)*(4*storyHgt(n)/sum(Kc(n,:)) + ...
        (storyHgt(m)+storyHgt(n))/sum(Kb(m,:)) + ...
        (storyHgt(n)+storyHgt(o))/sum(Kb(n,:))));
end
R(end) = 48*Es/(storyHgt(end)*(4*storyHgt(end)/sum(Kc(end,:)) + ...
    (2*storyHgt(end-1)+storyHgt(end))/sum(Kb(end-1,:)) + ...
    storyHgt(end)/sum(Kb(end,:))));

% Drift
V_story = flip(cumsum(flip(Fx)));
SDR = (V_story./R)./storyHgt;

end