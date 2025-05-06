% ----------------------------------------------------------------------- %
% Function plot_areaerrorbar plots the mean and standard deviation of a   %
% set of data filling the space between the positive and negative mean    %
% error using a semi-transparent background, completely customizable.     %
%                                                                         %
%   Input parameters:                                                     %
%       - data:     Data matrix, with rows corresponding to observations  %
%                   and columns to samples.                               %
%       - options:  (Optional) Struct that contains the customized params.%
%           * options.handle:       Figure handle to plot the result.     %
%           * options.color_area:   RGB color of the filled area.         %
%           * options.color_line:   RGB color of the mean line.           %
%           * options.alpha:        Alpha value for transparency.         %
%           * options.line_width:   Mean line width.                      %
%           * options.x_axis:       X time vector.                        %
%           * options.error:        Type of error to plot (+/-).          %
%                   if 'std',       one standard deviation;               %
%                   if 'sem',       standard error mean;                  %
%                   if 'var',       one variance;                         %
%                   if 'c95',       95% confidence interval.              %
% ----------------------------------------------------------------------- %
%   Example of use:                                                       %
%       data = repmat(sin(1:0.01:2*pi),100,1);                            %
%       data = data + randn(size(data));                                  %
%       plot_areaerrorbar(data);                                          %
% ----------------------------------------------------------------------- %
%   Author:  Victor Martinez-Cagigal                                      %
%   Date:    30/04/2018                                                   %
%   E-mail:  vicmarcag (at) gmail (dot) com                               %
% ----------------------------------------------------------------------- %

%
%     options.handle     = gca;
%     options.color_area = min((rgb/255)+brighter, [1 1 1]);    % Blue theme
%     options.color_line = rgb/255;
%     options.alpha      = 0.5;
%     options.line_width = 2;
%     options.error      = 'sem';
%     options.x_axis = xx;
%     plot_areaerrorbar_joon(fr, options);


function plot_areaerrorbar_joon(data, options)

    % Default options
    if(nargin<2)
        figure(1);
        options.handle     = gca;
        options.color_area = [128 193 219]./255;    % Blue theme
        options.color_line = [ 52 148 186]./255;
        %options.color_area = [243 169 114]./255;    % Orange theme
        %options.color_line = [236 112  22]./255;
        options.alpha      = 0.5;
        options.line_width = 2;
        options.error      = 'std';
    end
    if(isfield(options,'x_axis')==0), options.x_axis = 1:size(data,2); end
    options.x_axis = options.x_axis(:);
    
    % Computing the mean and standard deviation of the data matrix
%     data_mean = mean(data,1);
%     data_std  = std(data,0,1);
    %joon add. treat nan.
    data_mean = nanmean(data,1);
    data_std  = nanstd(data,0,1);
    
    % Type of error plot
    switch(options.error)
        case 'std', error = data_std;
        case 'sem', error = (data_std./sqrt(size(data,1)));
        case 'var', error = (data_std.^2);
        case 'c95', error = (data_std./sqrt(size(data,1))).*1.96;
    end
    
    %joon add. treat nan.
    data_mean_filled = data_mean;
    data_mean_filled = fillmissing(data_mean_filled,'movmedian',1000); 
    error = fillmissing(error,'movmedian',1000); 
    
    % Plotting the result
%     figure(options.handle);
    axes(options.handle);
    x_vector = [options.x_axis', fliplr(options.x_axis')];
    hold on;
    patch = fill(x_vector, [data_mean_filled+error,fliplr(data_mean_filled-error)], options.color_area);
    set(patch, 'edgecolor', 'none');
    set(patch, 'FaceAlpha', options.alpha);
    plot(options.x_axis, data_mean, 'color', options.color_line, ...
        'LineWidth', options.line_width);
    hold off;
    
end