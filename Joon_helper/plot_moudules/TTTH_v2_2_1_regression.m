function [corr_val, p_val, regress_b, reg_x, reg_y, p_scatter, p_reg_line]= TTTH_v2_2_1_regression(axes_cur, dat, ...
    dot_color, is_plot_regression, is_plot_scatter)
%dat: dat(:,1) x values, dat(:,2) y values.
% dot_color: rgb color (0~1)
% axes_cur: axis to plot, no plotting if empty.

%return values.
%r: correlation coefficient
%p: p value
%regress_b(1): y intercept
%regress_b(2): x slope

p_scatter = [];
p_reg_line = [];
%%

b = regress(dat(:,2),[ones(size(dat(:,1))) dat(:,1)]);  % linear regression
reg_x = [min(dat(:,1)) max(dat(:,1))];	 % x-values for plotting regression line
reg_y = b(1) + b(2).*reg_x;                                   % y-values for plotting regression line
[r p]= corrcoef(dat(:,1),dat(:,2));    % find correlation between variables
corr_val = r(1,2);
p_val = p(1,2);

if ~isempty(axes_cur)
%     axes(axes_cur);
    hold on;
    
    if is_plot_scatter
        p_scatter = scatter(axes_cur, dat(:,1),dat(:,2),'o', 'MarkerEdgeColor', dot_color,'LineWidth',0.5);
    end
    if is_plot_regression
        p_reg_line = plot(axes_cur, reg_x,reg_y,'-', 'color',dot_color);               % plot regression line
    end
end

regress_b = b;
end
