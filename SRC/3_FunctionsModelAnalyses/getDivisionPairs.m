% getDivisionPairs gets all the unique pairs of integers [A,B] such that A*B = X
function pairs = getDivisionPairs(X)

pairs = [];
for i = 2:X-1
    j = X/i;
    if round(j) == j % is integer
        if ~ismember(i, pairs)
            pairs = [pairs; [i, j]];        
        end
    end
end

end