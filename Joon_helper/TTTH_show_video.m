function TTTH_show_video(imgs)
fig_position = [100 100 500 500];
pause_sec = 0.1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('color',[1 1 1],'position',fig_position);
set(gca,'position',[0 0 1 1],'units','normalized');
sz = size(imgs);
if length(sz)==2
    imshow(imgs(:,:,1));
elseif length(sz)==3
    hp = imshow(imgs(:,:,1));
    for i=1:sz(end)
        hp.CData = imgs(:,:,i);
        pause(pause_sec);
    end
elseif length(sz)==4
    hp = imshow(imgs(:,:,:,1));
    for i=1:sz(end)
        hp.CData = imgs(:,:,:,i);
        pause(pause_sec);
    end
end
    
end