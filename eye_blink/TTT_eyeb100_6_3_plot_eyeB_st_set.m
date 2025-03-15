function [fig1, ax1] = TTT_eyeb100_6_3_plot_eyeB_st_set(eye_st_set, n_days, plot_type)
%%
fig_position = [100 100 1500 1000];
fig_size_days = 8; %fix to 10days

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if n_days > fig_size_days
    fig_size_days = n_days;
end
set(groot, 'DefaultAxesTickLabelInterpreter', 'none');
m_ids = {eye_st_set.mouse_id};
uniq_m_id = unique(m_ids);
fig1 = figure('color',[1 1 1],'position',fig_position);
p_row = length(uniq_m_id); p_col = fig_size_days;
for m=1:length(uniq_m_id) %m=3
    idx = find(strcmp(m_ids,uniq_m_id{m}));
    sub_set = eye_st_set(idx);
    if length(sub_set) > 1 %sorting.
        T = struct2table(sub_set); % convert the struct array to a table
        sortedT = sortrows(T, 'day_no'); % sort the table by 'DOB'
        sub_set = table2struct(sortedT); % change it back to struct array if necessary
        sub_set = sub_set(1:min([n_days length(sub_set)]));
    end
    
    for i=1:length(sub_set) %i=4
        eyeB_st = sub_set(i);
%         ax1 = subplot(p_row,p_col,(m-1)*n_days + i); hold on;
        ax1 = subplot(p_row,p_col,(m-1)*fig_size_days + i); hold on;
    %     TTT_eyeb100_5_1_plot_eyeB_st(eyeB_st, ax1);
%         TTT_eyeb100_5_2_plot_eyeB_st(eyeB_st, ax1, is_perc_plot);
        TTT_eyeb100_5_3_plot_eyeB_st(eyeB_st, ax1, plot_type);
        title([eyeB_st.mouse_id ', Day' num2str(eyeB_st.day_no)],'interpreter','none');
    end
end
end

