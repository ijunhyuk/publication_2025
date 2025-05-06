function cv2 = TTTH_get_spike_cv2(spike_tp)
% spike_tp: time points of spikes.
% 
    if length(spike_tp)<3
        cv2 = nan;
    else
        isi = diff(spike_tp);
        for i=1:length(isi)-1
            cv2s(i) = 2*abs(isi(i+1)-isi(i))/(isi(i+1)+isi(i));
        end
        cv2 = nanmean(cv2s);
    end

end