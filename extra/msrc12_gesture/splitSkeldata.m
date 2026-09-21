
% Demo 1: Visualize a sequence.
%
% Author: Sebastian Nowozin <Sebastian.Nowozin@microsoft.com>

drc1 = 'data';
drc2 = 'splitData';
skelfile_1 = '%s/P%01d_%01d_%01d_p%02d';
skelfile_2 = '%s/P%01d_%01d_%01dA_p%02d';
count = 0;
for a=1:9
    for style1 = 1:3
        for style2 = 1:2
            for s = 1:30
                
                if exist(sprintf([skelfile_1 '.csv'],drc1,style1,style2,a,s),'file')
                    count = count + 1;
                    [X,Y,tagset]=load_file(sprintf(skelfile_1,drc1,style1,style2,a,s));
                    T=size(X,1);
                    frame_id = find(Y(:,a)==1);
                    seg_num = length(frame_id);
                    X_segment = cell(1,seg_num);
                    for i = 1:seg_num-1
                        X_segment{i} = X(frame_id(i):frame_id(i+1)-1,:);
%                         X_segment{i}(:,4:4:80) = [];
                        fprintf('%d of 594 :: Subject %d Action %d Style1 %d Style2 %d Recording %d ...\n ',count,s,a,style1,style2,i);
                        dlmwrite(sprintf('%s/P%02d_%02d_%02d_p%02d_r%02d.txt',drc2,style1,style2,a,s,i),X_segment{i},'delimiter',' ');
                    end
                end
                if exist(sprintf([skelfile_2 '.csv'],drc1,style1,style2,a,s),'file'),
                    count = count + 1;
                    [X,Y,tagset]=load_file(sprintf(skelfile_2,drc1,style1,style2,a,s));
                    T=size(X,1);
                    frame_id = find(Y(:,a)==1);
                    seg_num = length(frame_id);
                    X_segment = cell(1,seg_num);
                    for i = 1:seg_num-1
                        X_segment{i} = X(frame_id(i):frame_id(i+1)-1,:);
                        %                             X_segment{i}(:,4:4:80) = [];
                        fprintf('%d of 594 :: Subject %d Action %d Style1 %d Style2 %d Recording %d ...\n ',count,s,a,style1,style2,i);
                        dlmwrite(sprintf('%s/P%02d_%02d_%02dA_p%02d_r%02d.txt',drc2,style1,style2,a,s,i),X_segment{i},'delimiter',' ');
                    end
                end
                
            end 
        end
    end
end


skelfile_1 = '%s/P%01d_%01d_%02d_p%02d';
skelfile_2 = '%s/P%01d_%01d_%02dA_p%02d';
for a=10:12
    for style1 = 1:3
        for style2 = 1:2
            for s = 1:30
                
                if exist(sprintf([skelfile_1 '.csv'],drc1,style1,style2,a,s),'file')
                    count = count + 1;
                    [X,Y,tagset]=load_file(sprintf(skelfile_1,drc1,style1,style2,a,s));
                    T=size(X,1);
                    frame_id = find(Y(:,a)==1);
                    seg_num = length(frame_id);
                    X_segment = cell(1,seg_num);
                    for i = 1:seg_num-1
                        X_segment{i} = X(frame_id(i):frame_id(i+1)-1,:);
%                         X_segment{i}(:,4:4:80) = [];
                        fprintf('%d of 594 :: Subject %d Action %d Style1 %d Style2 %d Recording %d ...\n ',count,s,a,style1,style2,i);
                        dlmwrite(sprintf('%s/P%02d_%02d_%02d_p%02d_r%02d.txt',drc2,style1,style2,a,s,i),X_segment{i},'delimiter',' ');
                    end
                end
                if exist(sprintf([skelfile_2 '.csv'],drc1,style1,style2,a,s),'file'),
                    count = count + 1;
                    [X,Y,tagset]=load_file(sprintf(skelfile_2,drc1,style1,style2,a,s));
                    T=size(X,1);
                    frame_id = find(Y(:,a)==1);
                    seg_num = length(frame_id);
                    X_segment = cell(1,seg_num);
                    for i = 1:seg_num-1
                        X_segment{i} = X(frame_id(i):frame_id(i+1)-1,:);
                        %                             X_segment{i}(:,4:4:80) = [];
                        fprintf('%d of 594 :: Subject %d Action %d Style1 %d Style2 %d Recording %d ...\n ',count,s,a,style1,style2,i);
                        dlmwrite(sprintf('%s/P%02d_%02d_%02dA_p%02d_r%02d.txt',drc2,style1,style2,a,s,i),X_segment{i},'delimiter',' ');
                    end
                end
                
            end    
        end
    end
end


