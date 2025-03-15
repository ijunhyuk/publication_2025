function load_video_frames(video_path, frame_range)
    % video_path: the video that we want to see.
    % frame_range: ex) [1 500], means we will see frame1 - frame500

    video_path = '\\research.files.med.harvard.edu\Neurobio\NEUROBIOLOGY SHARED\Regehr\Joon\EyeBlink\Data\m792\B1_20220920_144924.mp4';
    trial_no = 3;

    frame_range = [1 560] + 560*(trial_no-1);
    
    vr_ir = VideoReader(video_path);
    f_ir = read(vr_ir, frame_range);

    
    for i=1:size(f_ir,4)
        imshow(f_ir(:,:,:,i));
        pause(0.01);
    end
        

end