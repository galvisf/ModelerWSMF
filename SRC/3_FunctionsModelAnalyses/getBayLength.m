function [bayLength] = getBayLength(TowerBayLengths)
    % Bay Lengths
    TowerBayLengths = TowerBayLengths{1};
    TowerBayLengths = erase(TowerBayLengths,' ');
    TowerBayLengths = split(TowerBayLengths(2:end-1),',');
    bayLength = zeros(length(TowerBayLengths),1);
    for i = 1:length(TowerBayLengths)
        bayLength(i) = str2double(TowerBayLengths(i))*12;
    end
end