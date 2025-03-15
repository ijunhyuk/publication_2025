function TTT_vor_1000_3_1_processing_vor_trial_further()
%% peak gain from average: --> it is not effective. just use the previous way.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vor_trial_suffix = '_processed.mat';

data_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data';
mouse_fo = 'm792_test';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

target_fo = [data_fo filesep mouse_fo];
filelist_st = TTTH_search_all_files([target_fo], 1, vor_trial_suffix);
filelist_st = sortrows(filelist_st,1);

figure();
for i=1:length(filelist_st)
    %do whatever here.
    
end
    
%% 20231205. Add property to structure. minimum_perc_successful_gain
target_fo_arr = {};
target_fo_arr{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\a6_TKO';
% target_fo_arr{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO';
% target_fo_arr{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\PC_TKO';
% target_fo_arr{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\KPPF';

minimum_perc_successful_gain = 30;

for t=1:length(target_fo_arr)
    target_fo = target_fo_arr{t};
    file_list = TTTH_search_all_files([target_fo], 1, '*_processed.mat');
    for i=1:length(file_list)
        cur_file = file_list{i};
        temp = load(cur_file);
        vor_trial = temp.vor_trial;
        vor_trial.analysis_param.minimum_perc_successful_gain = minimum_perc_successful_gain;
        save(cur_file,'vor_trial');
    end
    % analysis_param.minimum_perc_successful_gain
end
disp('finished!!!');
end

