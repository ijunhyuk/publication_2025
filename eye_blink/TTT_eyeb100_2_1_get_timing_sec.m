function [LED_onset, LED_offset, puff_onset, puff_offset] = TTT_eyeb100_2_1_get_timing_sec(param_mat, trial_no)
%%
% 20221102. Joon.

%output
% LED_onset - the video frame number when LED is on in this trial.
% LED_offset - the video frame number when LED is off in this trial.
% puff_onset - the video frame number when air puff is on in this trial.
% puff_offset - the video frame number when air puff is off in this trial.
% same for the other outpus.

% manual parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rec_freq = 280; %video is actually 280 Hz.
camclk_on_dur = 2; %sec.
LED_onset = 0.5; %sec.
LED_offset = 1.05; %sec.
puff_onset = 1.0; %sec.
puff_offset = 1.05; %sec.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
rec_dur = rec_freq*camclk_on_dur;

idx_LED = rec_dur*(trial_no-1) + [LED_onset*rec_freq+1, LED_offset*rec_freq];
idx_puff = rec_dur*(trial_no-1) + [puff_onset*rec_freq+1, puff_offset*rec_freq];

LED_onset = idx_LED(1);
LED_offset = idx_LED(2);
puff_onset = idx_puff(1);
puff_offset = idx_puff(2);

end