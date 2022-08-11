function [PS_mean, PS_median] = computeMeansGMset(GM,SF,spectraName)

n_T = length(GM(1).(spectraName));
n_gm = length(GM);

PS_mean = zeros(n_T, 1);
PS_median = zeros(n_T, 1);
for T_i = 1:n_T
    temp = zeros(n_gm, 1);
    for gm_i = 1:n_gm
        temp(gm_i) = SF(gm_i)*GM(gm_i).(spectraName)(T_i);
    end
    PS_mean(T_i) = mean(temp);
    PS_median(T_i) = geomean(temp);
end

end
