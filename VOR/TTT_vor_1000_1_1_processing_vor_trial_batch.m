function TTT_vor_1000_1_1_processing_vor_trial_batch()
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mouse_fo = {};
is_overwrite_vor_trial = 0;

data_fo = 'M:\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\';

group_fo = 'PC_TKO\PC_TKO_batch4';
mouse_fo{end+1} = [group_fo filesep 'm1181'];
mouse_fo{end+1} = [group_fo filesep 'm1182'];
mouse_fo{end+1} = [group_fo filesep 'm1183'];

t_total = tic;
for i=1:length(mouse_fo)
    TTT_vor_1000_1_4_processing_vor_trial(data_fo, mouse_fo{i}, is_overwrite_vor_trial)
end
disp('Batch process all finished!!');
toc(t_total);

end