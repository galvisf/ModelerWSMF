function [storyHeight] = genStoryHeight(nStories,typicalStoryHeight,AtypicalStoryHeight)
    
    storyHeight = round(ones(nStories,1)*typicalStoryHeight*12,0);
    
    % Atypical Stories
    atypicalStories = AtypicalStoryHeight{1};
    atypicalStories = erase(atypicalStories,' ');
    if ~isempty(atypicalStories)
        cellList = split(atypicalStories,'],[');
        %     atypical = zeros(length(cellList),2);
        for i = 1:length(cellList)
            atyp = cellList{i};
            atyp = erase(atyp,'[');
            atyp = erase(atyp,']');
            atyp = split(atyp,',');
            storyHeight(str2double(atyp{1})) = round(str2double(atyp{2})*12,0);
        end
    end
end