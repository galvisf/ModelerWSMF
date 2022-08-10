% reformatForOutput takes a vector and format it as a string. If input is a
% cell of more than one size, the output is a cell with strings
%
% INPUTS
%   in = cell of the form: {[1,2,3,4]}
%
% OUTPUT
%   out = cell of the form {'[1,2,3,4]'}
%
function out = reformatForOutput(in)

out = cell(length(in),1);
if ~iscell(in) == 1
    out = ['[', regexprep(mat2str(in'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
else
    for i = 1:length(in)
        if ~isempty(in{i})
            out{i} = ['[', regexprep(mat2str(in{i}'), {'\[', '\]', '\s+'}, {'', '', ','}), ']'];
        end
    end
end
end