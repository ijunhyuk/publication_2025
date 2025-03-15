function TTT_vor_1000_8_1_make_mp4_from_jpeg()
%%
pupil_fos = {}; %project_fo should have ex) m861\motor_performance\Pupil_20221113_192310
% project_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\temp\Syt7_m861_m862_m864';
% project_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\Syt7_m861_m862_m864';
% project_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\Syt7_m861_m862_m864_2nd_Rp';
% project_fo{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\GC_TKO_m831_m834';
pupil_fos{end+1} = 'D:\Joon\supercom_dropbox\Dropbox (HMS)\BigData_HMS\VOR\VOR_data\temp\m1014_Pupil_20230706_105842';

img_ext = 'jpeg';
img_suffix = {'c1','c2','c3','c4','c5','c6','c7'};
inclue_sub_folders = 1;
video_hz = 5;
is_delete_img = 1; %after mp4 made, delete the image?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for p=1:length(pupil_fos)
    cur_fo = pupil_fos{p};
    file_list = TTTH_get_all_files(cur_fo, inclue_sub_folders, img_ext);
    for s=1:length(img_suffix)
        suf = img_suffix{s};
        tf = contains(file_list,suf);
        cur_list = file_list(tf);
        %         s = sortrows(cur_list);
        disp(['Search for ' cur_fo ', ' suf '... ' num2str(length(cur_list)) 'images found.']);
        if isempty(cur_list)
            continue;
        end
        [fo,fi,ext] = fileparts(cur_list{1});
        idx_suf = strfind(fi,suf);
        
        video_name = [fi(1:idx_suf+length(suf)-1) '_images' num2str(length(cur_list)) '.mp4'];
        video_path = [fo filesep video_name];
        vw = VideoWriter(video_path,'MPEG-4');
        vw.FrameRate = video_hz;
        open(vw);
        for m=1:length(cur_list)
            writeVideo(vw,imread(cur_list{m}));
        end
        close(vw);
        %         vr = VideoReader(video_path);
        %         ff = readFrame(vr);
        %         figure();
        %         imshow(aa)
        %         imshow(ff)
        disp(['Video is made from ' num2str(length(cur_list)) ' images: ' video_path]);
        
        if is_delete_img
            for m=1:length(cur_list)
                delete(cur_list{m});
            end
            disp([num2str(length(cur_list)) ' images were deleted after video generation.']);
        end
        
    end
end
disp(['finished!!!']);

end