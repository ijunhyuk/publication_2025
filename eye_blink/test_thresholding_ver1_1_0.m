%%%%%%%%%%%%%%%%%%%%% parameters start
% 데이터 폴더 경로
data_fo = 'D:\Joon\Joon_git_superCOM2\Joon_EyeBlink\test_data\';

% 비디오 파일명
video_filename = 'm1012_day5_B1_20230724_144032.mp4';

% 눈동자 검출을 위한 파라미터
eye_threshold = 30; % 눈동자 검출을 위한 임계값 (낮춤)
min_area = 20; % 최소 눈동자 영역 크기를 더 작게 조정
max_areas = 3; % 허용할 최대 영역 수

% 동적 임계값 계산을 위한 파라미터
std_multiplier = 1.5; % 표준편차 곱셈 인자 (낮춤)

% 모폴로지 연산을 위한 구조 요소 크기
se_size = 3; % 구조 요소 크기 줄임

% 객체 중심과 이미지 중심 사이의 최대 허용 거리 (이미지 대각선의 분수)
max_distance_fraction = 4; % 1/3로 설정 (중심에서 더 멀리 있는 객체도 허용)

% 타원 모양 판단을 위한 이심률 임계값
eccentricity_threshold = 0.9; % 높임 (더 다양한 형태 허용)

% 오버레이 투명도
overlay_alpha = 0.4; % 약간 더 진하게 설정

% 임계값 계산을 위한 파라미터
threshold_offset = 30; % 평균 intensity에서 뺄 값

%%%%%%%%%%%%%%%%%%%% parameters end

% 비디오 경로 설정
video_path = [data_fo video_filename];

% 비디오 객체 생성
v = VideoReader(video_path);

% 총 프레임 수 계산
total_frames = v.NumFrames;

% 프레임 수 출력
fprintf('총 프레임 수: %d\n', total_frames);

% 560으로 나눈 값 계산 및 출력
number_of_trial = total_frames / 560;
fprintf('560으로 나눈 값, 총 trial 수: %.2f\n', number_of_trial);

% 첫 번째 trial의 평균 intensity 계산
v.CurrentTime = 0;  % 비디오 객체를 처음으로 되감기
total_intensity = 0;
for frame = 1:560
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    total_intensity = total_intensity + mean(gray_frame(:));
end
average_intensity = total_intensity / 560;

% 고정 임계값 설정
fixed_threshold = average_intensity - threshold_offset;

fprintf('평균 intensity: %.2f\n', average_intensity);
fprintf('고정 임계값: %.2f\n', fixed_threshold);

% 비디오 작성을 위한 객체 생성
% 현재 날짜와 시간을 기반으로 date_str 생성
current_datetime = datetime('now');
date_str = datestr(current_datetime, 'yyyymmdd_HHMMSS');

output_video_path = [data_fo 'eye_detection_result_' date_str '.mp4'];
output_video = VideoWriter(output_video_path);
open(output_video);

% 프레임 처리 및 비디오 작성
v.CurrentTime = 0;  % 비디오 객체를 처음으로 되감기
for frame = 1:560
    current_frame = readFrame(v);
    gray_frame = rgb2gray(current_frame);
    
    % 고정 임계값 적용
    binary_eye = gray_frame < fixed_threshold;
    
    % 모폴로지 연산을 사용하여 눈 영역 개선
    se = strel('disk', se_size);  % 구조 요소 생성
    binary_eye = imclose(binary_eye, se);  % 닫기 연산
    binary_eye = imfill(binary_eye, 'holes');  % 구멍 채우기
    
    % 작은 객체 제거
    binary_eye = bwareaopen(binary_eye, min_area);
    
    % 연결 요소 레이블링
    cc = bwconncomp(binary_eye);
    stats = regionprops(cc, 'Area', 'Eccentricity', 'Centroid');
    
    % 영역 크기에 따라 정렬
    [~, idx] = sort([stats.Area], 'descend');
    
    % 최대 max_areas 개의 큰 영역만 선택
    selected_areas = min(max_areas, length(idx));
    idx = idx(1:selected_areas);
    
    % 선택된 영역만 유지
    binary_eye = false(size(binary_eye));
    for i = 1:selected_areas
        binary_eye(cc.PixelIdxList{idx(i)}) = true;
        
        % 객체의 중심점 계산
        object_center = stats(idx(i)).Centroid;
        
        % 이미지 중심점 계산
        [height, width] = size(binary_eye);
        image_center = [width/2, height/2];
        
        % 객체 중심과 이미지 중심 사이의 거리 계산
        distance_to_center = norm(object_center - image_center);
        
        % 중심에서의 최대 허용 거리
        max_distance = sqrt(width^2 + height^2) / max_distance_fraction;
        
        % 타원 모양에 가깝고 중앙에 위치한 객체만 유지
        if stats(idx(i)).Eccentricity > eccentricity_threshold || distance_to_center > max_distance
            binary_eye(cc.PixelIdxList{idx(i)}) = false;
        end
    end
    
    % 눈 영역을 반투명 노란색으로 표시
    yellow_mask = cat(3, ones(size(binary_eye)), ones(size(binary_eye)), zeros(size(binary_eye)));
    alpha = overlay_alpha;  % 투명도 설정 (0: 완전 투명, 1: 불투명)
    overlay = im2double(current_frame);
    for c = 1:3
        overlay(:,:,c) = overlay(:,:,c) .* (1 - alpha * binary_eye) + yellow_mask(:,:,c) .* (alpha * binary_eye);
    end
    
    % 프레임 번호 표시
    overlay = insertText(overlay, [10 10], sprintf('프레임: %d', frame), 'FontSize', 18, 'BoxColor', 'white', 'BoxOpacity', 0.4, 'TextColor', 'black');
    
    % 비디오에 프레임 추가
    writeVideo(output_video, overlay);
end

% 비디오 객체 닫기
close(output_video);

fprintf('비디오 생성 완료: eye_detection_result.avi\n');


