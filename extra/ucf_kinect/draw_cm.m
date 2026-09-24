function draw_cm(mat, tick, num_class)
%%
%  Matlab code for visualization of confusion matrix;
%              tick: name of each class, e.g. 'class_1' 'class_2'...
%              num_class: number of class
%
%           Blog: www.shamoxia.com;
%           QQ:379115886;
%           Email: peegeelee@gmail.com
%%
imagesc(1:num_class, 1:num_class, mat);            %#in color
% pcolor(1:num_class,1:num_class,mat);
colormap(flipud(gray));  %#for gray; black for large value.  % original version
% colormap(pink);

textStrings = num2str(mat(:), '%0.2f');
textStrings = strtrim(cellstr(textStrings));
for i = 1:num_class * num_class
    if strcmp(textStrings(i, :), num2str(0.00, '%0.2f')) == 1
        textStrings{i, :} = ' ';
    end
end
for i = 1:num_class * num_class
    if strcmp(textStrings(i, :), num2str(100.00, '%0.2f')) == 1
        textStrings{i, :} = num2str(100.00, '%0.1f');
    end
end
[x, y] = meshgrid(1:num_class);
% hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');% original version
hStrings = text(x(:), y(:), textStrings(:), 'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
midValue = mean(get(gca, 'CLim'));
textColors = repmat(mat(:) > midValue, 1, 3);  % original version
% textColors = repmat(mat(:) < midValue,1,3);
set(hStrings, {'Color'}, num2cell(textColors, 2));  %#Change the text colors
set(gca, 'FontSize', 14)
axis image;
axis xy;

set(gca, 'xticklabel', tick, 'XAxisLocation', 'bot');
set(gca, 'XTick', 1:num_class, 'YTick', 1:num_class);
set(gca, 'yticklabel', tick);
% rotateXLabels(gca, 315 );% rotate the x tick
