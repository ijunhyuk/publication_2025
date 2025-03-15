function [] = TTT_eyeb100_8_1_make_eyeB_batch_st()
%%
%% add up many eye_st_set.mat  into eye_blink_batch1.mat
drop_box_fo = 'M:\Dropbox (HMS)';

batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO'];
save_batch_mat_path = [batch_fo '\eye_blink.mat'];

adding = {};
f_name = '\eye_st_set.mat';

adding{end+1} = ['M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO\PC-TKO_m1205-m1209\summary' f_name];
adding{end+1} = ['M:\Dropbox (HMS)\BigData_HMS\EyeBlink\EyeBlink_Data\PC-TKO\PC-TKO_m1181-m1184\summary' f_name];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(adding)
    temp = load(adding{i});
    cur_set = temp.eye_st_set;
    if i==1
        batch_st = cur_set;
    else
        batch_st = [batch_st; cur_set];
    end
end

% sorting
T = struct2table(batch_st); % convert the struct array to a table
sortedT = sortrows(T, {'day_no','mouse_id'}); % sort the table by 'DOB'

%stats
uniq_id = unique(sortedT.mouse_id);
n_mice = length(uniq_id);
disp(['### Number of mice: ' num2str(n_mice) '###']);
for m=1:n_mice
    cur_id = uniq_id{m};
    idx = find(contains(sortedT.mouse_id, cur_id));
    days = sortedT.day_no(idx);
    disp([num2str(m) ': ' cur_id ', days:' num2str(days')]);
end

batch_set = table2struct(sortedT); % change it back to struct array if necessary
save(save_batch_mat_path, 'batch_set');
disp(['batch_set is saved!!! ' save_batch_mat_path]);

end
