function color_map = TTTH_make_v1_0_0_color_map(count,map_name)
%     count = 4;
    if isempty(map_name)
        color_map = hsv(count); 
    elseif strcmp(map_name, 'hsv')
        color_map = hsv(count); 
    end
    
end
