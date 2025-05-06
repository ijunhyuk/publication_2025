function TTTH_convert_avi_to_mp4(original_path, ...
    fr_ratio, play_speed, read_time, img_resize, bright,...
    save_avi, save_tiff, save_stacked_tiff, save_mp4, superficial_fr)
%%%% 설정값 시작 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% original_path: video path to read. ex) 'c:\aaa.avi'
% fr_ratio: down sampling ratio. Eg) 1:not change, 0.5: reduce to half Hz.
% play_speed: to show faster or slower movie. ex) 2: two times faster, 1/2: two times slower.
% read_time: crop specific period. ex) [0 10]: 0sec-10sec crop
% img_resize: change video image size. ex) [480 640]: 480 height, 640 width

[pathstr, name, ext] = fileparts(original_path);
save_f = [pathstr filesep 'converted'];
if ~exist(save_f)
    mkdir(save_f);
end
% save_avi: if true, video will saved with suffixed name in the same folder.
% avi_path = [pathstr filesep name '_' datestr(now,'yyyymmdd_HHMMSS') '.avi'];
avi_path = [save_f filesep name '.avi'];
mp4_path = [save_f filesep name '.mp4'];
% save_tiff: if true, video will saved as tif image file in following subfoler in the same folder.
tiff_folder_path = [save_f filesep name];
% save_stacked_tiff: if true, video will saved as stacked tif image file in the same folder.
stacked_tiff_path = [save_f filesep name '.tif'];
%%%% 설정값 끝 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vid = VideoReader(original_path);
v_fr = vid.FrameRate;
v_width = vid.Width;
v_height = vid.Height;
num_f = vid.NumFrames;
frame = readFrame(vid);
dim_sz = numel(size(frame));
save_fr = 0;

if save_mp4
    if dim_sz==2
        disp(['Error!!! Original video is grayscale. mustbe rgb format to convert to Mp4, original video: ' original_path]);
        return;
    end
end
vid = VideoReader(original_path);

if isempty(fr_ratio)
    save_fr = v_fr;
else
    save_fr = round(v_fr*fr_ratio);
end
if isempty(play_speed)
    play_speed = 1;
end

if isempty(read_time)
    read_time = [1/v_fr num_f/v_fr];
end
read_idx = round([read_time(1)*v_fr:v_fr/save_fr:read_time(2)*v_fr]);

jump = round(v_fr/save_fr);
%%
if save_mp4    
    if dim_sz==3
        vw = VideoWriter(mp4_path, 'MPEG-4');
    end
%     vw.Quality = 100;
    vw.FrameRate = round(save_fr*play_speed);
    open(vw);
    count = 0;
    while hasFrame(vid)
        frame = readFrame(vid);
        count = count+1;
        if rem(count, jump)==1
            if ~isempty(img_resize)
                frame = imresize(frame,img_resize);
            end
            if ~isempty(bright)
                frame = frame.*bright;
            end
            writeVideo(vw,frame);            
        end
    end
    close(vw);    
end

if save_avi
    if dim_sz==3
        vw = VideoWriter(avi_path);
    elseif dim_sz==2
        vw = VideoWriter(avi_path, 'Grayscale AVI');
    end
    % v.Quality = 50;
    vw.FrameRate = round(save_fr*play_speed);
    open(vw);
    count = 0;
    while hasFrame(vid)
        frame = readFrame(vid);
        count = count+1;
        if rem(count, jump)==1
            if ~isempty(img_resize)
                frame = imresize(frame,img_resize);
            end
            if ~isempty(bright)
                frame = frame.*bright;
            end
            writeVideo(vw,frame);            
        end
    end
    close(vw);    
end

if save_tiff
    if ~isfolder(tiff_folder_path); mkdir(tiff_folder_path); end
    count = 0;
    while hasFrame(vid)
        frame = readFrame(vid);
        count = count+1;
        if rem(count, jump)==1
            path = [tiff_folder_path filesep num2str(count) '.tif'];
            if ~isempty(img_resize)
                frame = imresize(frame,img_resize);
            end
            if ~isempty(bright)
                frame = frame.*bright;
            end
            imwrite(frame, path);
        end
    end
end

if save_stacked_tiff
    count = 0;
    while hasFrame(vid)
        frame = readFrame(vid);
        count = count+1;
        if rem(count, jump)==1
            path = [tiff_folder_path filesep num2str(count) '.tif'];
            if ~isempty(img_resize)
                frame = imresize(frame,img_resize);
            end
            if ~isempty(bright)
                frame = frame.*bright;
            end
            imwrite(frame, stacked_tiff_path,'WriteMode','append');
        end
    end
end

end