function parsed_st = TTT_vor_1000_2_4_parse_vor_name(filelist_relative)
%% 
%ex) 20230307_113508_0_2Hz_OKR_processed.mat
%ex) 20230307_114850_1Hz_VOR_processed.mat

idx_date = 1:8;
idx_time = 10:15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(filelist_relative)
    cur_mat = filelist_relative{i};
    [fo,fi,ext] = fileparts(cur_mat);
    hz_idx = strfind(fi,'Hz_');
    suffix_idx = strfind(fi,'_processed');
    
    date_str = fi(idx_date);
    time_str = fi(idx_time);
    hz_str = fi(idx_time(end)+2:hz_idx-1);
    if contains(hz_str,'_')
        tok = strsplit(hz_str,'_');
        stim_hz = str2num(tok{1}) + str2num(tok{2})*0.1;
    else
        stim_hz = str2num(hz_str);
    end
    exp_type_str = fi(hz_idx+3:suffix_idx-1);
    
    parsed_st(i).date_str = date_str;
    parsed_st(i).time_str = time_str;
    parsed_st(i).stim_hz = stim_hz;
    parsed_st(i).exp_type_str = exp_type_str;      
end

% get day No.
date_arr = {parsed_st.date_str};
uniq_date = unique(date_arr);
for i=1:length(parsed_st)
    day_no = find(contains(uniq_date,date_arr{i}));
    parsed_st(i).day_no = day_no;      
end

end