function [] = TTT_eyeb100_8_4_change_eyeB_batch_st()
%% Change wrong mouse_id, etc.
%
drop_box_fo = 'M:\Dropbox (HMS)';

% batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1-2'];
% batch_mat_path = [batch_fo '\eye_blink_batch1-2.mat'];

batch_fo = [drop_box_fo '\BigData_HMS\EyeBlink\EyeBlink_Data\GC-TKO_batch1-2\GC-TKO_day9_test'];
batch_mat_path = [batch_fo '\eye_blink_day9_batch_revision.mat'];

change_mouse_id = {}; %{id_from, id_to}. e.g., {'1001', 'm1001'; '1002', 'm1002'}
change_mouse_id(end+1,:) = {'1001', 'm1001'};
change_mouse_id(end+1,:) = {'1002', 'm1002'};
change_mouse_id(end+1,:) = {'1004', 'm1004'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp = load(batch_mat_path);
batch_set = temp.batch_set;

batch_set_mid = {batch_set.mouse_id};
for i=1:size(change_mouse_id,1)
    cur_from_id = change_mouse_id{i,1};
    cur_to_id = change_mouse_id{i,2};
    idx = find(contains(batch_set_mid, cur_from_id));
    for j=1:length(idx)
        batch_set(idx(j)).mouse_id = cur_to_id;
    end
end

save(batch_mat_path, 'batch_set');
disp(['batch_set is revised!!! ' batch_mat_path]);

end
