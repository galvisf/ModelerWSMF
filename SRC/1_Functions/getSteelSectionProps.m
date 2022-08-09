function props = getSteelSectionProps(sectionSize, AISC_v14p1)
% getSteelSectionProps reads/computes steel section geometrical properties
% 
% INPUTS
%   sectionSize = String with name of the section (any in database)
%                 'FL' armed section 'FL tf x bf + Web tw x dw' 'FL #.###x##.### + Web #.###x##.###'
%                       dw is only the web plate
%                 'BUILT' Built or armed section 'BUILT db-bf-tw-tf' 'BUILT ##.##-##.##-#.###-#.###'
%                 'BOX' Box section 'BOX db-bf-tw-tf' 'BOX ##.##-##.##-#.###-#.###'
%                       dw and bf are both outer dimensions
%   AISC_v14p1  = AISC section profile database
%
% OUTPUT
%   props = structure with all section properties
%           db
%           bf
%           tf
%           tw
%           A
%           Iz
%           Sz
%           Zz
%           Iy
%           Sy 
%           Zy
%           tPZ_z
%           tPZ_y
%           J
%           Cw
%
%%
    % Reformat section name    
    sectionSize = sectionSize(~isspace(sectionSize)); % remove spaces
%     sectionSize
    if contains(sectionSize, 'x')
        sectionSize = strrep(sectionSize, 'x', 'X');
    end
    
    % Search in database
    idx_sec = find(strcmp(AISC_v14p1(:, 3), sectionSize));
    props = struct;       
    
    if isempty(idx_sec) && iscell(sectionSize)
        % for built-up or box sections
        sectionSize = sectionSize{1};
    end
    
    if ~isempty(idx_sec)
        % Standard section
        props.db = AISC_v14p1{idx_sec, 7};
        props.bf = AISC_v14p1{idx_sec, 12};
        props.tf = AISC_v14p1{idx_sec, 20};
        props.tw = AISC_v14p1{idx_sec, 17};
        
        props.A = AISC_v14p1{idx_sec, 6};
        props.h_tw = AISC_v14p1{idx_sec, 36};
        props.Iz = AISC_v14p1{idx_sec, 39}; % around strong axis
        props.Sz = AISC_v14p1{idx_sec, 41}; 
        props.Zz = AISC_v14p1{idx_sec, 40};
        props.Iy = AISC_v14p1{idx_sec, 43}; % around weak axis
        props.Sy = AISC_v14p1{idx_sec, 45};
        props.Zy = AISC_v14p1{idx_sec, 44};
        props.J = AISC_v14p1{idx_sec, 50}; % torsional constant
        props.Cw = AISC_v14p1{idx_sec, 51}; % warpping" constant
        
        props.tPZ_z = props.tw; % strong axis (web)
        props.tPZ_y = 2*props.tf; % weak axis (flanges)
    elseif contains(sectionSize, 'FL') || contains(sectionSize, 'BUILT')                 
        % Built-up section
		if contains(sectionSize, 'FL')
			sSectionSize = split(sectionSize, 'X'); % split at "X"
			props.db = str2double(sSectionSize{end});
			props.tf = str2double(sSectionSize{1}(3:end));
			sSectionSize = split(sSectionSize{2}, '+');
			props.bf = str2double(sSectionSize{1});
			props.tw = str2double(sSectionSize{2}(4:end));
        else
            sSectionSize = split(sectionSize, '-');
            if length(sSectionSize) == 4
                props.db = str2double(sSectionSize{1}(6:end)); % total depth of the section
                props.bf = str2double(sSectionSize{2});
                props.tw = str2double(sSectionSize{3});
                props.tf = str2double(sSectionSize{4});
            else                
                props.db = str2double(sSectionSize{2}); % total depth of the section
                props.bf = str2double(sSectionSize{3});
                props.tw = str2double(sSectionSize{4});
                props.tf = str2double(sSectionSize{5});
            end
		end
        props.dw = props.db - 2*props.tf; % Total depth of the section in strong
        
        props.A = props.dw*props.tw + 2*props.tf*props.bf;
        props.h_tw = props.dw/props.tw;
        props.Iz = 1/12*(props.dw^3*props.tw + 2*props.tf^3*props.bf) + ...
            2*props.tf*props.bf*(props.dw/2 + props.tf/2)^2; % around strong axis
        props.Sz = 2*props.Iz/props.db; 
        props.Zz = props.bf*props.tf*(props.db - props.tf) + 0.25*props.tw*(props.db - 2*props.tf)^2;
        props.Iy = 1/12*(props.dw*props.tw^3 + 2*props.tf*props.bf^3); % around weak axis
        props.Sy = 2*props.Iy/props.bf;
        props.Zy = props.bf^2*props.tf/2 + 0.25*props.tw^2*(props.db - 2*props.tf);        
        props.J  = (2*props.bf*props.tf^3 + (props.db - props.tf)*props.tw^3)/3; % torsional constant neglecting fillets
        props.Cw = ((props.db - props.tf)^2*props.bf^3*props.tf)/24; % warpping constant ignoring fillets
        
        props.tPZ_z = props.tw; % strong axis (web)
        props.tPZ_y = 2*props.tf; % weak axis (flanges)
    else
        % Box section
        sSectionSize = split(sectionSize, '-');              
        if length(sSectionSize) == 4
            props.db = str2double(sSectionSize{1}(4:end));
            props.bf = str2double(sSectionSize{2});
            props.tw = str2double(sSectionSize{3});
            props.tf = str2double(sSectionSize{4});
        else
            props.db = str2double(sSectionSize{2});
            props.bf = str2double(sSectionSize{3});
            props.tw = str2double(sSectionSize{4});
            props.tf = str2double(sSectionSize{5});
        end        
        
        props.A = 2*props.db*props.tw + 2*props.tf*(props.bf-2*props.tw);
        props.h_tw = min((props.db - 2*props.tf)/props.tw, ...
                         (props.bf - 2*props.tw)/props.tf);
        props.Iz = 1/12*(2*props.db^3*props.tw + 2*props.tf^3*(props.bf-2*props.tw)) + ...
            2*props.tf*(props.bf-2*props.tw)*(props.db/2 - props.tf/2)^2; % around strong axis
        props.Sz = 2*props.Iz/props.db; 
        props.Zz = props.bf*props.tf*(props.db - props.tf) + 2*props.tw*(props.db - 2*props.tf)^2/4;
        props.Iy = 1/12*(2*props.db*props.tw^3 + 2*props.tf*(props.bf-2*props.tw)^3) + ...
            2*props.tw*props.db*(props.bf/2 - props.tw/2)^2; % around weak axis
        props.Sy = 2*props.Iy/props.bf;
        props.Zy = props.db*props.tw*(props.bf - props.tw) + 2*props.tf*(props.bf - 2*props.tw)^2/4;
        
        
        props.tPZ_z = 2*props.tw; % strong axis (web)
        props.tPZ_y = 2*props.tf; % weak axis (flanges)
    end
    
    % Compute J and Cw if not included (assume section is wide-flange)
    if ~isfield(props, 'J') || isempty(props.J)
        props.J  = (2*props.bf*props.tf^3 + (props.db - props.tf)*props.tw^3)/3; % torsional constant neglecting fillets        
    end
    if ~isfield(props, 'Cw') || isempty(props.Cw)
        props.Cw = ((props.db - props.tf)^2*props.bf^3*props.tf)/24; % warpping constant ignoring fillets        
    end

end