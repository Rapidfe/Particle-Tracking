function a2_detect_particles
% makes [frame_num  x_coordinate  y_coordinate] data file

s_raiz = 'a';
umbral_1 = 50;      % binarize threshold
umbral_2 = 255;     % only detect umbral_1<=...<=umbral_2
area_1 = 25;        % area threshold
area_2 = 250;
elipse = 0.85;          % eccentricity value
dir_1= '.\tracking_output\video_frames\';% folder where the images are.
dir_2= '.\tracking_output\';     % folder where the data will be saved
formato='.tif';         % format of the image file
n_number=5;             % number of digit in order to diferenciate the images.Ej: a_001.tif, a_002.tif , ... => n_number=3
refresco=10;            % number of displaying 'Figure' between pauses.
isDisp = 0;             % display images or not? 0:no 1:yes



close all
set(0,'defaulttextinterpreter','none');

% get size of image
files=dir(strcat(dir_1,s_raiz,'*',formato));
nfiles=length(files);
image_cali=imread(strcat(dir_1,files(1).name));
[n_rows,n_columns]=size(image_cali);
clear files image_cali;

% detect particles in all frames
data=[];
disp_progress = 0;
for n=1:nfiles
    while (n/nfiles*100)>=disp_progress
        fprintf('%d%%...\n', disp_progress)
        disp_progress = disp_progress+5;
    end
    
    % make file name
    n_zeros=n_number-length(num2str(n));
    cero='0';
    while (length(cero)<n_zeros),
        cero=strcat(cero,'0');
    end
    s=strcat(s_raiz,'_',cero,num2str(n),formato);

    % read grayscale and make new array
    A=imread(strcat(dir_1,s));
    A = rgb2gray(A);
    I=zeros(size(A));

    % binarize
    cambiar=find(([A]>=umbral_1)&([A]<=umbral_2));
    I(cambiar)=1;
    I=imfill(I,'holes');
    I=imclearborder(I);
    if isDisp
        subplot(2,2,1), imshow(I);
        title('binarize');
    end
    
    % area filter
    [labeled,numObjects] = bwlabel(I);    % searching clusters: labeled and propierties
    balldata = regionprops(labeled,'Area');
    if ((area_1~=0) | (area_2~=0)) 
        selected = find(([balldata.Area]>=area_1)&([balldata.Area]<=area_2));
        I = ismember(labeled,selected);
    end
    if isDisp
        subplot(2,2,2), imshow(I);
        title('area_filter');
    end
    
    % eccentricity filter
    [labeled,numObjects] = bwlabel(I);
    balldata = regionprops(labeled,'Eccentricity');
    if (elipse~=1)
        selected = find([balldata.Eccentricity]<=elipse); 
        I = ismember(labeled,selected);
    end
    if isDisp
        subplot(2,2,3), imshow(I);
        title('eccentricity_filter');
    end

    % get centers
    centers = [];
    [labeled,numObjects] = bwlabel(I);
    balldata = regionprops(labeled,'Area','BoundingBox','Eccentricity');
    if (~isempty(balldata))     % centroids
        for k=1:numObjects      % calculating the centroid with weighted for brightness
            clear grays row column;
            [row,column]=find(labeled==k);              % coodinates of the selected area
            grays=double(A((column-1)*n_rows+row));     % gray scale of the selected area
            x_gray(k)=column'*grays/sum(grays);
            y_gray(k)=row'*grays/sum(grays);
        end
        clear grays row column;
        centers=[n*ones(length(balldata),1) x_gray' y_gray'];
        clear x_gray y_gray;
    end
    if (~isempty(centers))
        data=[data;centers]; %guardar datos
    end
       
    % display progress
    if isDisp && mod(n,refresco)==0
        disp(n);
        subplot(2,2,4), imshow(A);
        hold on;
        if(~isempty(centers))
            plot(centers(:,2),centers(:,3),'or','MarkerSize',2)
        end
        title(strcat('RESULT: ',s));
        w = waitforbuttonpress;
        if w==0
            return;
        end
        hold off;
    end
    clear centers;
end

save(strcat(dir_2,'detect_each_frames.dat'),'data','-ASCII');
