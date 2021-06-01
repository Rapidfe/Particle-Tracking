function a1_get_frames

dir = '.\sample.mp4';             % video directory
sav = '.\tracking_output';                 % output directory



sav = strcat(sav,'\video_frames\');
[status,msg] = mkdir(sav);
if status==1
    delete(strcat(sav,'a_*.tif'));
end
len = 5;                        % bigger than digit of total frames
v = VideoReader(dir);
cnt = v.NumFrames;
disp_progress = 0;
for i=1:cnt
    video = readFrame(v);
    img_num = num2str(i);
    for n=1:len-length(img_num)
        img_num = strcat('0',img_num);
    end
    imwrite(video,strcat(sav,'a_',img_num,'.tif'),'tif');
    while (i/cnt*100)>=disp_progress
        fprintf('%d%%...\n', disp_progress)
        disp_progress = disp_progress+5;
    end
end
