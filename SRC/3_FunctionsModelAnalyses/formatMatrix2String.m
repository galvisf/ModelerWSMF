% formatMatrix2String takes a 2D matrix and format it as a string to save
% in a CSV
%
% INPUTS
%   in = cell with 2D matrices, each to format as a string
%
% OUTPUT
%   formatedVector = cell of strings representation each matrix from in
% 
function formatedVector = formatMatrix2String(in)

% Read prop and loc input into vectors
formatedVector = cell(length(in),1);
for i = 1:length(in)
    if ~isempty(in{i})
        if any(size(in{i})==1)
            % 1D vector
            formatedVector{i} = [regexprep(mat2str(in{i}), {';'}, {','})];
        else
            % 2D matrices
            formatedVector{i} = [regexprep(mat2str(in{i}), {'\[', '\]', ';', ' '}, {'[[', ']]', '],[', ','})];
        end
    end
end

end