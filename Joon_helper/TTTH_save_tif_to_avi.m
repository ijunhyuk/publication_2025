% make a mp4 video file to test deeplabcut

dirName = '\\research.files.med.harvard.edu\neurobio\NEUROBIOLOGY SHARED\Regehr\ForJoon\M75\210311\pupil';
crop = 1;

fileList = TTT_d2_2_ver1_getAllFiles(dirName, 0, 'tiff');

image_st = imfinfo(fileList{1});
num_images = size(image_st,1);
width = image_st.Width;
hight = image_st.Height;
color_type = image_st.ColorType;
compression = image_st.Compression;
bit_depth = image_st.BitDepth;

files_arr = {};
% files_arr{end+1} = [1:1000];
% files_arr{end+1} = [1:1000]+10000;
% files_arr{end+1} = [1:1000]+20000;
% files_arr{end+1} = [1:1000]+30000;
% files_arr{end+1} = [1:1000]+40000;
% files_arr{end+1} = [1:1000]+50000;

files_arr{end+1} = [2:50001];

% files_arr{end+1} = [1:10];

crop_pos = [];
if crop
    loop = 1;
    while loop
        img = imread(fileList{1});
        imshow(img);
        box_roi = drawrectangle(gca,'Label','Crop','FaceAlpha',0.1,'Position',[250 150 100 100]);
        str = input('push enter when you finish adjusting roi.','s');
        crop_pos = box_roi.Position;
        img_crop = imcrop(img,crop_pos);
        imshow(img_crop);
        str = input('Satisfied (enter)? Go back and Draw again (b)?','s');
        if ~strcmp(str,'b')
            loop = 0;
        end
    end
end

for kk=1:length(files_arr)
    files = files_arr{kk};
    [fo,fi,ext] = fileparts(fileList{files(1)});    
    [fo2,~,~] = fileparts(fo);
    video_filename = [fo2 filesep fi '.mp4'];
    disp(['Save avi into ... ' video_filename ]);
    outputVideo = VideoWriter(video_filename, 'MPEG-4');
    outputVideo.FrameRate = 10;
    open(outputVideo);
    for i=files        
        writeVideo(outputVideo, imcrop(imread(fileList{i}),crop_pos));
    end
    close(outputVideo);
    disp(['Finished!']);
end
