function cv = TTTH_get_spike_cv(spike_tp)
% spike_tp: time points of spikes.
% 
    if length(spike_tp)<2
        cv = nan;
    else
        isi = diff(spike_tp);
        cv = nanstd(isi)/nanmean(isi);
    end

end