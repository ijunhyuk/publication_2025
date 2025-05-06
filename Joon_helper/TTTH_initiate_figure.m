function [figure1] = TTTH_initiate_figure(in_fig_size, visible_flag)
% in_fig_size = [10 10 70 70]; %화면의 left bottom width height 퍼센트크기
    % plotting prepare - start
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     in_fig_size = in_fig_size/100;
%     scrsz = get(0,'ScreenSize');
%     scrsz = [1 1 1920 1080];
%     left = scrsz(3)*in_fig_size(1);
%     bottom = scrsz(4)*in_fig_size(2);
%     width = scrsz(3)*in_fig_size(3);
%     height = scrsz(4)*in_fig_size(4);
%     cur_size = [left bottom width height];
    cur_size = [in_fig_size(1) in_fig_size(2) in_fig_size(3) in_fig_size(4)];
    
    if(visible_flag)
        figure1 = figure('Visible','on', 'Position',cur_size, 'Color',[1 1 1]);
    else
        figure1 = figure('Visible','off', 'Position',cur_size, 'Color',[1 1 1]);
    end
    % plotting prepare - end
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end