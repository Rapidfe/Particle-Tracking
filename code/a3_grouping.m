function a3_grouping

distance = 17;  % limit distance to recognize same particle between next frame 
lostn = 4;      % if a particle disappear for 'lostn'frames, stop tracking this particle
deln = 50;      % if a particle's frame is less than 'deln', don't save this particle
dir_images= '.\tracking_output\video_frames\';   % folder where the images are.
dir_output= '.\tracking_output\';                % folder where the data will be saved
n_number=5;



dir_output2= strcat(dir_output,'particles\');
lcut = 1;       % 마지막 한번 더 버리기 (0: no, 나머지: yes)
[status,msg] = mkdir(dir_output2);
delete(strcat(dir_output2,'a_*.dat'));          % 이전 output파일 모두 삭제
dir_tmp = strcat(dir_output,'detect_each_frames.dat');
centers = load(dir_tmp);
[st ed] = size(centers);

x = 1;                     % 시작프레임
y = centers(st);           % 끝프레임
img_num = num2str(y);
for i=1:5-length(img_num)
    img_num = strcat('0',img_num);
end
dir_tmp = strcat(dir_images,'a_',img_num,'.tif');
img = imread(dir_tmp);
imshow(img);
title(strcat('a_',img_num,'.tif'));
hold on;

start = 1;
group = [];
disp_progress = 0;
for i=x:y
    while (i/(y-x+1)*100)>=disp_progress
        fprintf('%d%%...\n', disp_progress)
        disp_progress = disp_progress+10;
    end
    
    A1 = [];
    if i>x
        A1 = A1_tmp;
    end
    A2 = [];
    counting = 1;
    for n=start:st
        if (i==x) && (centers(n,1)==i)
            A1 = [A1 ; centers(n,:) counting 0];  % counting: 그룹번호, 0: 다음트래킹 안됐을 때 카운트
            counting = counting+1;
        end
        if centers(n,1)==i+1
            A2 = [A2 ; centers(n,:)];
        end
        if centers(n,1)>i+1
            start = n;
            break;
        end
    end
    if i==x
        group = A1(:,1:4);
    end
    A1_tmp = [];
    A1_size = size(A1);
    for n=1:A1_size(1)
        A3 = [];
        fr_A3 = 0; fc_A3 = 0;
        A2_size = size(A2);
        if A2_size(1) ~= 0      % A2가 비면 계산 안함
            g_size = size(group);
            counting = 1;
            for sq=1:A2_size(1)
                A3 = [A3 ; sqrt((A1(n,2)-A2(sq,2))^2+(A1(n,3)-A2(sq,3))^2) counting];  % counting : A2의 열번호
                counting = counting+1;
            end
            [fr_A3,fc_A3] = find(A3(:,1)<distance & A3(:,1)==min(A3(:,1)),1);
            [fr_g,fc_g] = find(group(:,4)==A1(n,4),1,'last');       % group배열에서 지금 그룹번호인 데이터 중 가장 마지막 줄 위치 구하기
        end
        if fr_A3 > 0            % A2가 안비었고 다음 프레임에 이어지는게 있을 때 (A2가 비어있었으면 위에 계산을 안해서 fr_A3=0)
            add_num = A1(n,5)+1;
            if fr_g ~= g_size(1)
                group(g_size(1)+1:g_size(1)+add_num,:) = group(g_size(1)-add_num+1:g_size(1),:); % group배열 가장 끝줄 백업 %% 수정
                group(fr_g+add_num+1:g_size(1),:) = group(fr_g+1:g_size(1)-add_num,:); % 그룹번호 가장 끝줄(fr_g번째줄)에서 끝까지 데이터 백업
            end
            for g_fill=1:add_num-1
                x_fill = A1(n,2) - (A1(n,2)-A2(A3(fr_A3,2),2))/add_num*g_fill;
                y_fill = A1(n,3) - (A1(n,3)-A2(A3(fr_A3,2),3))/add_num*g_fill;
                group(fr_g+g_fill,:) = [A1(n,1)+g_fill x_fill y_fill A1(n,4)];
            end
            group(fr_g+add_num,:) = [A2(A3(fr_A3,2),:) A1(n,4)];
            A1_tmp = [A1_tmp ; A2(A3(fr_A3,2),:) A1(n,4) 0];
            A2(A3(fr_A3,2),:) = [];
        else % 뒤에 이어지는게 없을 때
            if A1(n,5) < lostn
                A1_tmp = [A1_tmp ; A1(n,1:4) A1(n,5)+1];
            else
                [fr_del,fc_del] = find(group(:,4)==A1(n,4));
                if size(fr_del,1)<deln
                    group(fr_del,:) = [];
                end
            end
        end
    end
    A2_size = size(A2); % 뒤가 남았을 때
    if A2_size(1)>0
        for n=1:A2_size(1)
            group(end+1,:) = [A2(n,:) group(end,4)+1];
            A1_tmp = [A1_tmp ; group(end,:) 0];
        end
    end
end
clear fr_del fc_del;
if lcut  % 마지막 한번 더 삭제하기
    g_sort = unique(group(:,4));
    for del_i=1:size(g_sort,1)
        [fr_del,fc_del] = find(group(:,4)==g_sort(del_i));
        if size(fr_del,1)<deln
            group(fr_del,:) = [];
        end
    end
end
clear fr_del fc_del;

g_sort = unique(group(:,4));
leg = [];
particle_num = 1;
for plot_i=1:size(g_sort,1)  % 그래프 + 범례 + 텍스트 + 입자별 저장
    %fprintf('particle: %d\n',plot_i);
    
    % 이름
    strnum = num2str(particle_num);
    particle_num = particle_num+1;
    while length(strnum)<n_number
        strnum=strcat('0',strnum);
    end
    % 입자별 저장
    [fr_del,fc_del] = find(group(:,4)==g_sort(plot_i));
    group_t = group(fr_del,:);
    dir_tmp = strcat(dir_output2,'a_',strnum,'.dat');
    save(dir_tmp,'group_t','-ASCII');
    % 그래프
    plot(group(fr_del,2),group(fr_del,3));
    % 텍스트
    leg_2 = strcat('a_',strnum,': ',num2str(group(fr_del(1),1)),'~',num2str(group(fr_del(end),1)));
    text(group(fr_del(1),2),group(fr_del(1),3),leg_2,'color','g','fontsize',10);
    % 범례
%     leg_1 = strcat(num2str(group(fr_del(1),1)),'~',num2str(group(fr_del(end),1)),'....',num2str(size(fr_del,1)),'frames');
%     leg = [leg ; string(leg_1)];
%     legend(leg,'Location','southwest');
end
%dir_tmp = strcat(dir_output,'group_raw.dat');
%save(dir_tmp,'group','-ASCII');

