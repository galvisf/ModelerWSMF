function Lcol = getColumnLengths(colSize, beamSize, storyHgt)
% getColumnLengths creates a matrix with the length of the column from top
% to bottom moment connection. This is important to use the correct lengths
% when having columns spaning several stories.
% The segments of a column that spans several stories will all have the
% same length that is the sum of the invidual story heights
% 
%%
storyNum = size(colSize,1);
pierNum = size(colSize,2);
bayNum = pierNum - 1;

Lcol = zeros(storyNum, pierNum);
col_joint = zeros(storyNum, pierNum);
% Compute column heights between moment connections
for i = 1:storyNum
    for j = 1:pierNum
        if ~isempty(colSize{i, j}) % jump setbacks
            % Beam index
            if j == pierNum
                beam_idx = j - 1;
            else
                beam_idx = j;
            end
            % Identify column type
            if j == 1 || j == pierNum || isempty(beamSize{i, beam_idx - 1})
                ext_col = true;
            else
                ext_col = false;
            end
            % Get column height
            if i == 1 || and(~isempty(beamSize{i-1, min(j, bayNum)}), ext_col) || ...
                and(~isempty(beamSize{i-1, j}), and(~isempty(beamSize{i, j}), ~ext_col)) % jump since no BC connection                               
            else                 
                % No BC connection
                col_joint(i, j) = 1;                
                col_joint(i-1, j) = 1;
            end
            Lcol(i, j) = storyHgt(i);  
        end
    end
end
% Fix lengths for columns spanning multiple stories
Ljoint = col_joint.*Lcol;
for j = 1:pierNum
    i = 1;
    while i <= storyNum
        if Ljoint(i, j) ~= 0
            Ltotal = Ljoint(i, j);
            for k = i+1:storyNum
                Ltotal = Ltotal + Ljoint(k, j);
                if Ljoint(k, j) == 0
                    break
                end
            end
            Lcol(i:k-1,j) = Ltotal;
            i = k;
        end
        i = i + 1;
    end
end

end