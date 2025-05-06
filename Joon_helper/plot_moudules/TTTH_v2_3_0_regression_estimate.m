function [y]= TTTH_v2_3_0_regression_estimate(regress_b, x)
% x: single value or array. ex) [1 2 3 3 4 5.6 7]
%regress_b(1): y intercept
%regress_b(2): x slope

    y = regress_b(1) + regress_b(2).*x;% y-values for plotting regression line
end
