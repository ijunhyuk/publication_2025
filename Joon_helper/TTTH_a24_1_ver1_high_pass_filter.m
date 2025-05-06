function [ret] = TTTH_a24_1_ver1_high_pass_filter(kData, fs, cut_freq, order)
% Start - TTT project specification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name : 
% Function : 
% Date & Programmer : 2014. 10. 20. Joonhyuk Lee.
% inputs :
% kData - data to be filtered.
% fs - sampling frequency
% cut_freq - cut off frequency
% order - filter order

% Date & Modifier : None.
% End - TTT project specification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fc = cut_freq; % cut-off frequency
    fn = fs/2; % Nyquist frequency
    filter_order = order; % Filter order
    [B1, A1]=butter(filter_order, fc/fn, 'high'); % band-pass filter design
    ret = filtfilt(B1,A1,kData); % Apply the filter()
    
end