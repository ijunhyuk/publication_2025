function [exp_type, exp_hz, exp_date_str] = TTT_vor_1001_1_1_identify_exp_type(vor_s, trial_fo)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
token = strsplit(trial_fo, '_');
exp_type = token{end};
exp_date_str = [token{1} '_' token{2}];

exp_hz = vor_s.table_rotation_command.zigzag_freq;

end