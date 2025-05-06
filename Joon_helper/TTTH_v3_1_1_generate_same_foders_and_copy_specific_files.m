function TTTH_v3_1_1_generate_same_foders_and_copy_specific_files()
%% Copy or Move specific files into the location with the same folder heirarchy
check_sub_dir = 1;
is_move = 0; %0 is copy, 1 is moving

tar_patterns = {};

% drop_fo = 'D:\Joon\supercom_dropbox\Dropbox (HMS)';
% from_fo = [drop_fo '\BigData_HMS\VOR\VOR_data\Syt7_m941_m943_m945'];
% to_fo = [drop_fo '\BigData_HMS\VOR\VOR_data\temp_bak_20230217\Syt7_m941_m943_m945'];
% tar_patterns{end+1} = '*saved40Hz_DLC.csv';
% tar_patterns{end+1} = '*20220920Sep20shuffle1_100000.h5';
% tar_patterns{end+1} = '*20220920Sep20shuffle1_100000_meta.pickle';

from_fo = ['\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon\VOR\Data\GC_TKO_m1001_m1002_m1004'];
to_fo = ['D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO_m1001_m1004'];
tar_patterns{end+1} = 'Radius_*.xlsx';


%%
if ~exist(to_fo)
    mkdir(to_fo);
end
list_xl_name = [to_fo '\copied_list_' datestr(now,'yyyymmdd_HHMMSS') '.xlsx'];
writecell({'copied from',from_fo; 'copied to', to_fo},list_xl_name);

for i=1:length(tar_patterns)
    str_pattern = tar_patterns{i};
    filelist = TTTH_search_all_files(from_fo, check_sub_dir, str_pattern);
    
    % make list for the files being copied.
    writecell(filelist,list_xl_name,'WriteMode','append');
    disp([str_pattern '... pattern detected in ' num2str(length(filelist)) ' files and being copied(or moved)...']);
    for f=1:length(filelist)
        cur_f = filelist{f};
        
        %make the tartget folder first.
        new_path = replace(cur_f,from_fo,to_fo);        
        [new_fo,fi,ext] = fileparts(new_path);
        if ~exist(new_fo)
            mkdir(new_fo);
        end
        
        %copy or move file.
        if is_move
            movefile(cur_f,new_path);
        else
            copyfile(cur_f,new_path);
        end
    end
end
disp(['Finished!!']);
end