% parameters start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 데이터 폴더 경로
data_fo = 'M:\Dropbox (HMS)\BigData_HMS\EyeBlink\temp\test_data\';

% 비디오 파일명
% video_filename = 'm1012_day5_B1_20230724_144032.mp4'; %ctr
% video_filename = 'm1026_day7_B1_20230726_153058.mp4'; %ctr
video_filename = 'm1024_day4_B1_20230723_193807.mp4'; %tko

save_fo = data_fo;

% 눈동자 검출을 위한 파라미터
eye_threshold = 30; % 눈동자 검출을 위한 임계값 (낮춤)
min_area = 20; % 최소 눈동자 영역 크기를 더 작게 조정
max_areas = 3; % 허용할 최대 영역 수

% 동적 임계값 계산을 위한 파라미터
std_multiplier = 1.5; % 표준편차 곱셈 인자 (낮춤)

% 모폴로지 연산을 위한 구조 요소 크기
se_size = 3; % 구조 요소 크기 줄임

% 객체 중심과 이미지 중심 사이의 최대 허용 거리 비율
max_distance_fraction = 0.1; % 이미지 대각선 길이의 30%로 설정

% 타원 모양 판단을 위한 이심률 임계값
eccentricity_threshold = 0.9; % 높임 (더 다양한 형태 허용)

% 오버레이 투명도
overlay_alpha = 0.4; % 약간 더 진하게 설정

% 임계값 계산을 위한 파라미터
threshold_offset = 30; % 평균 intensity에서 뺄 값

% 비디오 관련 파라미터
frame_rate = 280;
frames_per_trial = 560;
initial_frames = 140; % 0.5초 동안의 프레임 수

% parameters end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
warning off;

save_name = video_filename(1:5);
% 비디오 경로 설정
video_path = [data_fo video_filename];

% 비디오 객체 생성
v = VideoReader(video_path);

% 총 프레임 수 계산
total_frames = v.NumFrames;

% 프레임 수 출력
fprintf('총 프레임 수: %d\n', total_frames);

% frames_per_trial으로 나눈 값 계산 및 출력
number_of_trial = total_frames / frames_per_trial;
fprintf('frames_per_trial으로 나눈 값, 총 trial 수: %.2f\n', number_of_trial);

% 첫 번째 trial의 평균 intensity 계산
v.CurrentTime = 0;  % 비디오 객체를 처음으로 되감기
total_intensity = 0;
for frame = 1:frames_per_trial
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    total_intensity = total_intensity + mean(gray_frame(:));
end
average_intensity = total_intensity / frames_per_trial;

% 고정 임계값 설정
fixed_threshold = average_intensity - threshold_offset;

fprintf('평균 intensity: %.2f\n', average_intensity);
fprintf('고정 임계값: %.2f\n', fixed_threshold);

% 비디오 작성을 위한 객체 생성
% 현재 날짜와 시간을 기반으로 date_str 생성
current_datetime = datetime('now');
date_str = datestr(current_datetime, 'yyyymmdd_HHMMSS');

output_video_path = [data_fo 'detected_' save_name '_' date_str '.mp4'];
output_video = VideoWriter(output_video_path);
open(output_video);

% 첫 0.5초 동안의 눈 영역 파악
v.CurrentTime = 0;  % 비디오 객체를 처음으로 되감기
eye_regions = [];
for frame = 1:initial_frames
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    
    % 고정 임계값 적용
    binary_eye = gray_frame < fixed_threshold;
    
    % 모폴로지 연산을 사용하여 눈 영역 개선
    se = strel('disk', se_size);
    binary_eye = imclose(binary_eye, se);
    binary_eye = imfill(binary_eye, 'holes');
    
    % 작은 객체 제거
    binary_eye = bwareaopen(binary_eye, min_area);
    
    % 연결 요소 레이블링
    cc = bwconncomp(binary_eye);
    stats = regionprops(cc, 'Area', 'BoundingBox', 'Centroid');
    
    % 이미지 중심점 계산
    [height, width] = size(binary_eye);
    image_center = [width/2, height/2];
    
    % 이미지 대각선 길이 계산
    diagonal_length = sqrt(width^2 + height^2);
    
    % 최대 허용 거리 계산
    max_distance = diagonal_length * max_distance_fraction;
    
    % 가장 큰 영역 선택 (중심에서 최대 허용 거리 이내에 있는 영역 중에서)
    valid_regions = [];
    for i = 1:length(stats)
        object_center = stats(i).Centroid;
        distance_to_center = norm(object_center - image_center);
        if distance_to_center <= max_distance
            valid_regions = [valid_regions; i];
        end
    end
    
    if ~isempty(valid_regions)
        [~, idx] = max([stats(valid_regions).Area]);
        selected_region = valid_regions(idx);
        eye_regions = [eye_regions; stats(selected_region).BoundingBox];
    else
        eye_regions = [eye_regions; [0 0 0 0]];
    end
end

% 눈 영역의 평균 위치 계산
mean_eye_region = mean(eye_regions, 1);

% 눈 영역 크기를 저장할 배열
eye_sizes = zeros(frames_per_trial, 1);

% 프레임 처리 및 비디오 작성
v.CurrentTime = 0;  % 비디오 객체를 처음으로 되감기
for frame = 1:frames_per_trial
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    
    % 평균 눈 영역 주변으로 ROI 설정
    roi_x = max(1, round(mean_eye_region(1) - 20));
    roi_y = max(1, round(mean_eye_region(2) - 20));
    roi_width = min(size(gray_frame, 2) - roi_x + 1, round(mean_eye_region(3) + 40));
    roi_height = min(size(gray_frame, 1) - roi_y + 1, round(mean_eye_region(4) + 40));
    
    % ROI 내에서 눈 검출
    roi_gray = gray_frame(roi_y:roi_y+roi_height-1, roi_x:roi_x+roi_width-1);
    binary_eye = roi_gray < fixed_threshold;
    
    % 모폴로지 연산을 사용하여 눈 영역 개선
    binary_eye = imclose(binary_eye, se);
    binary_eye = imfill(binary_eye, 'holes');
    binary_eye = bwareaopen(binary_eye, min_area);
    
    % 연결 요소 레이블링
    cc = bwconncomp(binary_eye);
    stats = regionprops(cc, 'Area', 'PixelIdxList');
    
    % 가장 큰 영역 선택 및 눈 영역과의 거리 확인
    if ~isempty(stats)
        [max_area, max_idx] = max([stats.Area]);
        
        % 선택된 영역의 중심점 계산
        selected_pixels = false(size(binary_eye));
        selected_pixels(stats(max_idx).PixelIdxList) = true;
        selected_props = regionprops(selected_pixels, 'Centroid');
        selected_centroid = selected_props.Centroid;
        
        % 평균 눈 영역의 중심점 계산
        eye_region_center = [mean_eye_region(1) + mean_eye_region(3)/2, mean_eye_region(2) + mean_eye_region(4)/2];
        
        % 선택된 중심점을 원래 이미지 좌표로 변환
        selected_centroid_global = [roi_x + selected_centroid(1) - 1, roi_y + selected_centroid(2) - 1];
        
        % 두 중심점 사이의 거리 계산 (원래 이미지 좌표 기준)
        distance = norm(selected_centroid_global - eye_region_center);
        
        % 거리가 임계값보다 작으면 눈으로 간주
        if distance < max_distance
            eye_sizes(frame) = max_area;
            binary_eye = false(size(binary_eye));
            binary_eye(stats(max_idx).PixelIdxList) = true;
        else
            % 거리가 멀면 눈을 감은 상태로 간주
            eye_sizes(frame) = 0;
            binary_eye = false(size(binary_eye));
        end
    else
        eye_sizes(frame) = 0;
        binary_eye = false(size(binary_eye));
    end
    
    % 전체 이미지에서의 눈 영역 표시
    full_binary_eye = false(size(gray_frame));
    full_binary_eye(roi_y:roi_y+roi_height-1, roi_x:roi_x+roi_width-1) = binary_eye;
    
    % 눈 영역을 반투명 노란색으로 표시
    yellow_mask = cat(3, ones(size(full_binary_eye)), ones(size(full_binary_eye)), zeros(size(full_binary_eye)));
    alpha = overlay_alpha;
    overlay = im2double(current_frame);
    for c = 1:3
        overlay(:,:,c) = overlay(:,:,c) .* (1 - alpha * full_binary_eye) + yellow_mask(:,:,c) .* (alpha * full_binary_eye);
    end
    
    % 선택된 눈 영역의 픽셀 중심좌표를 불투명한 노란색 원으로 표시
    if ~isempty(stats) && distance < max_distance
        center_y = round(roi_y + selected_centroid(2) - 1);
        center_x = round(roi_x + selected_centroid(1) - 1);
        yellow_color = [255, 255, 0]/255; % 노란색 RGB
        circle_radius = 5; % 지름 10픽셀을 위한 반지름
        for dy = -circle_radius:circle_radius
            for dx = -circle_radius:circle_radius
                if abs(dy^2 + dx^2 - circle_radius^2) <= circle_radius
                    y = center_y + dy;
                    x = center_x + dx;
                    if y > 0 && y <= size(overlay, 1) && x > 0 && x <= size(overlay, 2)
                        overlay(y, x, :) = yellow_color;
                    end
                end
            end
        end
        
        % eye_region_center 위치를 파란색 점으로 표시
        blue_color = [0, 0, 255]/255; % 파란색 RGB
        blue_circle_radius = 3; % 지름 6픽셀을 위한 반지름
        eye_center_y = round(eye_region_center(2));
        eye_center_x = round(eye_region_center(1));
        for dy = -blue_circle_radius:blue_circle_radius
            for dx = -blue_circle_radius:blue_circle_radius
                if dy^2 + dx^2 <= blue_circle_radius^2
                    y = eye_center_y + dy;
                    x = eye_center_x + dx;
                    if y > 0 && y <= size(overlay, 1) && x > 0 && x <= size(overlay, 2)
                        overlay(y, x, :) = blue_color;
                    end
                end
            end
        end
    end
    
    % 프레임 번호 표시
    overlay = insertText(overlay, [10 10], sprintf('sec: %.3f', round(frame/frame_rate,3)), 'FontSize', 18, 'BoxColor', 'white', 'BoxOpacity', 0.4, 'TextColor', 'black');
    
    % 비디오에 프레임 추가
    writeVideo(output_video, overlay);
end

% 비디오 객체 닫기
close(output_video);

% 눈 크기 변화 그래프 그리기
figure;
time = (1:frames_per_trial) / frame_rate;
plot(time, eye_sizes);
xlabel('Frame');
ylabel('Eye Region Size (pixels)');
title('Eye Region Size Change over 2 Seconds');
grid on;
ylim([0 13000]);

% 그래프 저장
img_save_path = [save_fo 'graph_' save_name '_' date_str '.png'];
saveas(gcf, img_save_path);

fprintf('비디오 생성 완료: eye_detection_result.avi\n');


