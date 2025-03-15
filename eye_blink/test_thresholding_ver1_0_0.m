data_fo = 'D:\Joon\Joon_git_superCOM2\Joon_EyeBlink\test_data\';
video_path = [data_fo 'm1012_day5_B1_20230724_144032.mp4'];
% video_path = [data_fo 'm1026_day7_B1_20230724_144032.mp4'];

% 비디오 객체 생성
v = VideoReader(video_path);

% 총 프레임 수 계산
total_frames = v.NumFrames;

% 프레임 수 출력
fprintf('총 프레임 수: %d\n', total_frames);

% 560으로 나눈 값 계산 및 출력
frames_divided = total_frames / 560;
fprintf('560으로 나눈 값: %.2f\n', frames_divided);

% 눈동자 검출을 위한 파라미터 설정
eye_threshold = 50; % 눈동자 검출을 위한 임계값
min_area = 100; % 최소 눈동자 영역 크기

% 첫 번째 trial (560 프레임) 동안 눈 픽셀 개수 추적
eye_pixel_counts = zeros(1, 560);

for frame = 1:560
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    binary_eye = gray_frame < eye_threshold;
    binary_eye = bwareaopen(binary_eye, min_area);
    eye_pixel_counts(frame) = sum(binary_eye(:));
end

% 눈 픽셀 개수 변화 그래프 그리기
figure;
plot(1:560, eye_pixel_counts);
title('첫 번째 Trial 동안의 눈 픽셀 개수 변화');
xlabel('프레임');
ylabel('눈 픽셀 개수');

% 비디오 작성을 위한 객체 생성
output_video_path = [data_fo 'eye_detection_result.mp4'];
output_video = VideoWriter(output_video_path);
open(output_video);

% 프레임 처리 및 비디오 작성
v.CurrentTime = 0;  % 비디오 객체를 처음으로 되감기
for frame = 1:560
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    binary_eye = gray_frame < eye_threshold;
    
    % 모폴로지 연산을 사용하여 눈 영역 개선
    se = strel('disk', 5);  % 구조 요소 생성
    binary_eye = imclose(binary_eye, se);  % 닫기 연산
    binary_eye = imfill(binary_eye, 'holes');  % 구멍 채우기
    
    binary_eye = bwareaopen(binary_eye, min_area);  % 작은 객체 제거
    
    % 눈 영역을 반투명 노란색으로 표시
    yellow_mask = cat(3, ones(size(binary_eye)), ones(size(binary_eye)), zeros(size(binary_eye)));
    alpha = 0.3;  % 투명도 설정 (0: 완전 투명, 1: 불투명)
    overlay = im2double(current_frame);
    for c = 1:3
        overlay(:,:,c) = overlay(:,:,c) .* (1 - alpha * binary_eye) + yellow_mask(:,:,c) .* (alpha * binary_eye);
    end
    
    % 프레임 번호 표시
    overlay = insertText(overlay, [10 10], sprintf('Frame: %d', frame), 'FontSize', 18, 'BoxColor', 'white', 'BoxOpacity', 0.4, 'TextColor', 'black');
    
    % 비디오에 프레임 추가
    writeVideo(output_video, overlay);
end

% 비디오 객체 닫기
close(output_video);

fprintf('비디오 생성 완료: eye_detection_result.avi\n');

% 눈 픽셀 개수 변화 그래프 그리기
figure;
plot(1:560, eye_pixel_counts);
title('첫 번째 Trial 동안의 눈 픽셀 개수 변화');
xlabel('프레임');
ylabel('눈 픽셀 개수');


