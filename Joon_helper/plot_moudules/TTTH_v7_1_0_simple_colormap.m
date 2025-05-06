function colormap_custom = TTTH_v7_1_0_simple_colormap(color_start, color_end, n_colors)

    % 빨강 (RGB: [1, 0, 0])과 파랑 (RGB: [0, 0, 1])의 RGB 값을 정의
    red = color_start;
    blue = color_end;

    % 각 RGB 채널에 대해 선형 보간을 사용하여 컬러맵 생성
    r = linspace(red(1), blue(1), n_colors);
    g = linspace(red(2), blue(2), n_colors);
    b = linspace(red(3), blue(3), n_colors);

    % RGB 값을 결합하여 컬러맵 생성
    colormap_custom = [r' g' b'];
    
end