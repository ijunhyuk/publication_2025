function [pax] = TTTH_v3_1_0_polar_plot(fig1, ax, angles, values, dot_color_rgb, tranparency,matched_val_2pi)
% angles: ex) [90; 360]
% values: radius values. ex) 1.4, 100.2
% tranparency: 0 - 1. ex) 0.5
% dot_color:rgb. ex) [255 0 0]

color = dot_color_rgb/255; 
if isempty(ax)
    figure(fig1);
else
    axes(ax);
    hold on;
end

theta = angles*(2*pi/matched_val_2pi);
pt = polarscatter(theta,values,'o','MarkerFaceColor',color,...
    'MarkerFaceAlpha',tranparency,...
    'MarkerEdgeColor',color);

% rticklabels({'','aa','bb','cc','d'});

qua = 360/4;
thetaticks([0 qua*1 qua*2 qua*3]);
thetaticklabels({'0/100%','25%','50%','75%'});

pax = gca;
% pax.ThetaTickLabel = string(pax.ThetaTickLabel) + char(176);

if length(values) > 1
    space = mean(diff(values));
    rlim([values(1)-space values(end)+space]);
end

end