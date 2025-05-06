function TTTH_spike_heat_plot(ax1, data, color_map, c_limit, is_colorbar, y_labels)
%y_labels: cell type.
is_set_nan_transparent = 1; %set nan-value transparent.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis(ax1);
if isempty(color_map)
    color_map = hot;
end
if isempty(c_limit)
    c_limit = 'auto'; %c_limit = [0 2]; 
end

% surface(data);
% surf(T,F,10*log10(P),'edgecolor','none');
% surface([videodata.img_position(:,1)';videodata.img_position(:,1)'], [videodata.img_position(:,2)';videodata.img_position(:,2)']...
%     ,[zz';zz'], [velocity_z';velocity_z'],...
%     'facecol', 'no',...
%     'edgecol', 'interp',...
%     'linew', 1.5);
% 
% surf(data,'edgecolor','none');
% view(0,90);
% set(gca,'Ydir', 'reverse') % for some reason, matlab likes ot flip the Y axis. Unclear why it does this, so I flip it back

img_h = image(data,'CDataMapping','scaled');
colormap(ax1, color_map); caxis(c_limit);
set(gca,'TickDir','out'); 
if ~isempty(y_labels)
    yticks(1:length(y_labels));    
    yticklabels(y_labels);
    ax1.TickLabelInterpreter = 'none';
    %y label angle. ax1=gca;
    ytickangle(ax1, 30);
end
if is_colorbar
    colorbar;
end
if is_set_nan_transparent
    set(img_h, 'AlphaData', ~isnan(data));
end

end