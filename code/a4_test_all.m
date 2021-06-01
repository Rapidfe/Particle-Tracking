function a4_test_all

dir_images= '.\tracking_output\video_frames\';
dir_output= '.\tracking_output\particles\';
wait = 0.01;     % skip time






files=dir(strcat(dir_output,'a_*.dat'));
n_files = length(files);
idx = 1;
idxs=[]; data=[];
for i=1:n_files
    file = load(strcat(dir_output,files(i).name));
    idxs = [idxs; idx];
    data = [data; file];
    idx = idx+length(file);
end
idxs = [idxs; idx];
clear idx file files;

frame_st = data(1,1);
frame_ed = data(length(data),1);
name_frames = dir(strcat(dir_images,'a_*.tif'));
colors = ['oy','om','oc','or','og','ob'];
for f=frame_st:frame_ed
    img = imread(strcat(dir_images,name_frames(f).name));
    imshow(img);
    title(name_frames(f).name);
    hold on;
    for ff=1:n_files
        if data(idxs(ff),1)<=f
            this_end = idxs(ff)+f-data(idxs(ff),1);
            if this_end>idxs(ff+1)-1
                this_end = idxs(ff+1)-1;
            end
%             plot(data(idxs(ff):this_end,2),data(idxs(ff):this_end,3),colors(rem(ff,6)+1),'MarkerSize',1);
            plot(data(idxs(ff):this_end,2),data(idxs(ff):this_end,3));
        else
            break
        end
    end
    pause(wait);
    hold off;
end
