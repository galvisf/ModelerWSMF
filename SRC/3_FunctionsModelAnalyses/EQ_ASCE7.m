function Fx = EQ_ASCE7(bldgData, Ss, S1, TL, Ro, I, g)

%% Read relevant variables 
storyHgt = bldgData.storyHgt;

massFloor = (sum(bldgData.wgtOnBeam,2) + sum(bldgData.wgtOnCol,2) + bldgData.wgtOnEGF)/g;

%% Lateral load UBC (1973)
Sds = 2/3*Ss;
Sd1 = 2/3*S1;

T = 0.028*sum(storyHgt/12)^0.8;

Sa = DE_NEHRP(Sds, Sd1, TL, T)/(Ro/I);
if S1 >= 0.6
    Sa = max(Sa, 0.5*S1/(Ro/I));
end
Sa = max([Sa, 0.044*Sds*I, 0.01]);

Vs = Sa*sum(massFloor)*g;

if T < 0.5
    k = 1;
elseif T > 2.5
    k = 2;
else 
    k = 1 + (T - 0.5)/2;
end
Fx = (Vs)*massFloor.*cumsum(storyHgt.^k)./sum(massFloor.*cumsum(storyHgt.^k));

% Save lateral load patter file 
fid_r = fopen('EQ_ASCE7.tcl', 'wt');
fprintf(fid_r, 'set iFi {\n');
Fx_norm = Fx;
for i = 1:length(Fx)
    fprintf(fid_r, '\t%f\n', Fx_norm(i));
end
fprintf(fid_r,'}');
fclose(fid_r);

% Save lateral load response spectra
Ts = linspace(0, 10, 201);
Sa_s = DE_NEHRP(Sds, Sd1, TL, Ts)/(Ro/I);

fid_r = fopen('RS_ASCE7.tcl', 'wt');
fprintf(fid_r, 'set timeSeries_list_of_times_1 {');
for i = 1:length(Ts)
    fprintf(fid_r, '\t%f\n', Ts(i));
end
fprintf(fid_r,'}\n');
fprintf(fid_r, 'set timeSeries_list_of_values_1 {');
for i = 1:length(Sa_s)
    fprintf(fid_r, '\t%f\n', Sa_s(i));
end
fprintf(fid_r,'}\n');
fclose(fid_r);

end