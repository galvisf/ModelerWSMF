% formatVector takes two vectors (or formated strings) that specify a value
% (prop) that repeats the times specified in the loc vector and returns the
% vector with the prop repeated as specified.
%
% INPUTS
%   prop = vector or formated string with a list of values
%   loc  = vector or formated string with the repetitions of each value
%
% OUTPUT
%   formatVector = vector with all the prop values repeated as specified in
%                  loc
% 
function formatVector = formatInputByFloor(prop,loc)

% Read prop and loc input into vectors
if ischar(prop)
    str = strrep(prop, ' ', '');
    cellList = split(str,',');
    prop = zeros(length(cellList), 1);
    for i = 1:length(cellList)
        setb = cellList{i};
        setb = erase(setb,'[');
        setb = erase(setb,']');
        setb = split(setb,',');
        prop(i) = str2double(setb);
    end
end

if ischar(loc)
    str = strrep(loc, ' ', '');
    cellList = split(str,',');
    loc = zeros(length(cellList), 1);
    for i = 1:length(cellList)
        setb = cellList{i};
        setb = erase(setb,'[');
        setb = erase(setb,']');
        setb = split(setb,',');
        loc(i) = str2double(setb);
    end
end
% create a vector repeating each value in str the number of times specified
% in loc
formatVector = zeros(sum(loc), 1);
k = 1;
for i = 1:length(loc)
    formatVector(k:k-1+loc(i)) = prop(i);
    k = k + loc(i);
end

end