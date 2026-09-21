function draw_cm(mat,tick,num_class)
%%
%  Matlab code for visualization of confusion matrix;
%              tick: name of each class, e.g. 'class_1' 'class_2'...
%              num_class: number of class
%
%           Blog: www.shamoxia.com;  
%           QQ:379115886;  
%           Email: peegeelee@gmail.com
% for ntu3d dataset
% tick= {'drink water', 'eat meal/snack', 'brushing teeth', 'brushing hair', 'drop', 'pickup', 'throw', 'sitting down',...
% 'standing up','clapping', 'reading', 'writing', 'tear up paper', 'wear jacket', 'take off jacket',...
% 'wear a shoe','take off a shoe','wear on glasses','take off glasses','put on a hat/cap',...
% 'take off a hat/cap','cheer up','hand waving','kicking something','put something inside pocket',...
% 'hopping (one foot jumping)','jump up','make a phone call','playing with phone/tablet','typing on a keyboard',...
% 'pointing to something with finger','taking a selfie','check time (from watch)','rub two hands together',...
% 'nod head/bow','shake head','wipe face','salute','put the palms together','cross hands in front (say stop)',...
% 'sneeze/cough','staggering','falling','touch head (headache)','touch chest (stomachache/heart pain)',...
% 'touch back (backache)','touch neck (neckache)','nausea or vomiting condition','use a fan (with hand or paper)/feeling warm',...
% 'punching/slapping other person','kicking other person','pushing other person','pat on back of other person',...
% 'point finger at the other person','hugging other person','giving something to other person','touch other person''s pocket',...
% 'handshaking','walking towards each other','walking apart from each other'};% FOR NTU3D
%%
imagesc(1:num_class,1:num_class,mat);            %# in color
% pcolor(1:num_class,1:num_class,mat);  
colormap(flipud(gray));  %# for gray; black for large value.  % original version
% colormap(pink);

textStrings = num2str(mat(:),'%.2f'); 
textStrings = strtrim(cellstr(textStrings)); 
for i =1:num_class*num_class
    if strcmp(textStrings(i,:),num2str(0.00,'%0.2f')) == 1
        textStrings{i,:}=' ';
    end
    textStrings{i,:}(1)=[];
end
for i =1:num_class*num_class
    if strcmp(textStrings(i,:),num2str(100.00,'%0.2f')) == 1
        textStrings{i,:}=num2str(100.00,'%0.1f');
    end
end
[x,y] = meshgrid(1:num_class); 
% hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');% original version
hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center','FontSize',5);
midValue = mean(get(gca,'CLim')); 
textColors = repmat(mat(:) > midValue,1,3);  % original version
% textColors = repmat(mat(:) < midValue,1,3); 
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors
set(gca,'FontSize',8)
axis image;
axis xy;

set(gca,'xticklabel',tick,'XAxisLocation','bot');
set(gca, 'XTick', 1:num_class, 'YTick', 1:num_class);
set(gca,'yticklabel',tick);

set(gca,'xticklabel',tick);
rotateXLabels(gca, 315 );% rotate the x tick
%FOR MSRACTION3D
tick={'high arm wave',  'horizontal arm wave',  'hammer',  'hand catch',  'forward punch', 'high throw',  'draw x', 'draw tick', 'draw circle',  'hand clap',  'two hand wave', 'sideboxing', 'bend', 'forward kick', 'side kick', 'jogging', 'tennis swing', 'tennis serve', 'golf swing', 'pick up & throw'};% FOR MSRACTION3D
% for UT-KINECT
tick={'walk',  'sit down',  'stand up',  'pick up',  'carry', 'throw',  'push', 'pull', 'wave',  'clap hands'};
% FOR UCF-KINECT
tick={'balance',  'climbladder',  'climbup',  'duck',  'hop', 'kick',  'leap', 'punch', 'run',  'setpback',  'stepfront', 'stepleft', 'stepright', 'twistleft', 'twistright', 'vault'};
% for IP dataset
tick={'stop/yes',  'no/wipe',  'raise hand',  'hello/wave',  'left', 'right',  'up', 'down', 'front',  'back',  'swim', 'fly', 'clap', 'point left', 'point front', 'point right'}; 
%FOR NTU3D
tick= {'drink water', 'eat meal/snack', 'brushing teeth', 'brushing hair', 'drop', 'pickup', 'throw', 'sitting down',...
'standing up','clapping', 'reading', 'writing', 'tear up paper', 'wear jacket', 'take off jacket',...
'wear a shoe','take off a shoe','wear on glasses','take off glasses','put on a hat/cap',...
'take off a hat/cap','cheer up','hand waving','kicking something','put something inside pocket',...
'hopping (one foot jumping)','jump up','make a phone call','playing with phone/tablet','typing on a keyboard',...
'pointing to something with finger','taking a selfie','check time (from watch)','rub two hands together',...
'nod head/bow','shake head','wipe face','salute','put the palms together','cross hands in front (say stop)',...
'sneeze/cough','staggering','falling','touch head (headache)','touch chest (stomachache/heart pain)',...
'touch back (backache)','touch neck (neckache)','nausea or vomiting condition','use a fan (with hand or paper)/feeling warm',...
'punching/slapping other person','kicking other person','pushing other person','pat on back of other person',...
'point finger at the other person','hugging other person','giving something to other person','touch other person''s pocket',...
'handshaking','walking towards each other','walking apart from each other'};% FOR NTU3D




