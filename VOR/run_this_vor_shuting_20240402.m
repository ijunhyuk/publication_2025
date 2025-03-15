function run_this_vor()
%% Processing.
%Step 1_0: Convert *.avi to *.mp4 using matlab app.

%Step 2_0: Run dlc detection using Python code.

%Step 2_1: % There is an error if the csv file name is too long. Change file name % short
TTT_vor_1000_4_1_change_filename_short(); 

%Step 2_2: Rearrange day folders, also arrange Rp files in proper position.
TTT_vor_1000_4_2_move_folders_to_reorganize(); % rearrange folders.

%Step 3_0:
TTT_vor_1000_1_1_processing_vor_trial_batch();

%Step 4_0:
TTT_vor_1000_2_5_get_mouse_exp_map();
%Step 4_1:
TTT_vor_1000_2_2_plot_mouse();

%Step 5_1:
TTT_vor_1000_2_3_plot_group();
%Step 6_0:
TTT_vor_1000_3_1_processing_vor_trial_further();

end