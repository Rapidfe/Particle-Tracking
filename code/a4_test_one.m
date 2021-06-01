function a4_test_one

dir_images= '.\tracking_output\video_frames\';
dir_output= '.\tracking_output\particles\';
file = 5;        % file num
wait = 0.01;     % skip time
n_number=5;




strnum = num2str(file);
while length(strnum)<n_number
    strnum=strcat('0',strnum);
end
dir_tmp = strcat(dir_output,'a_',num2str(strnum),'.dat');
centers = load(dir_tmp);
st = centers(1,1);
ed = centers(size(centers,1),1);

for n=st:ed
    img_num = num2str(n);
    for i=1:5-length(img_num)
        img_num = strcat('0',img_num);
    end
    dir_tmp = strcat(dir_images,'a_',img_num,'.tif');
    img = imread(dir_tmp);
    imshow(img);
    title(strcat('a_',num2str(file),'.dat-->','a_',img_num,'.tif'));
    hold on;
    plot(centers(1:n-st+1,2),centers(1:n-st+1,3),'or','MarkerSize',1);
    
    pause(wait);
    hold off;
end