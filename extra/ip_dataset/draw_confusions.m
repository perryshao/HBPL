% load RECOGNITION_RATIO.mat
% load RECOGNITION_TALBLE_INTERG.mat;
m = length(confusion_matrix_diff);
n = size(confusion_matrix_diff{1, 1}, 1);
confusion_sum = zeros(n, n);
%% differential invariants
for i = 1:n
    %     name_class{i}=['class_' num2str(i)];
    name_class{i} = num2str(i);
end

for i = 1:m
    if ~isempty(confusion_matrix_diff{1, i})
        confusion_matrix_diff{1, i} = confusion_matrix_diff{1, i} ./ repmat(sum(confusion_matrix_diff{1, i}, 2), 1, n);
        confusion_matrix_diff{1, i} = confusion_matrix_diff{1, i} * 100;
        confusion_sum = confusion_sum + confusion_matrix_diff{1, i};
    else
        i = i - 1;
        break;
    end
end
confusion_table_diff = confusion_sum / i;
figure(1), draw_cm(confusion_table_diff, name_class, n);
%% sc
m = length(confusion_matrix_sc);
n = size(confusion_matrix_sc{1, 1}, 1);
confusion_sum = zeros(n, n);
for i = 1:n
    %     name_class{i}=['class_' num2str(i)];
    name_class{i} = num2str(i);
end
for i = 1:m
    if ~isempty(confusion_matrix_sc{1, i})
        confusion_matrix_sc{1, i} = confusion_matrix_sc{1, i} ./ repmat(sum(confusion_matrix_sc{1, i}, 2), 1, n);
        confusion_matrix_sc{1, i} = confusion_matrix_sc{1, i} * 100;
        confusion_sum = confusion_sum + confusion_matrix_sc{1, i};
    else
        i = i - 1;
        break;
    end
end
confusion_table_ssm = confusion_sum / i;
figure(2), draw_cm(confusion_table_ssm, name_class, n);
%% plot the precision_recall figure
predict_label = trainGID(I); actual_label = testGID;
for i = 1:n
    num_in_class(i) = length(predict_label(predict_label == i));
end
compute_precision_recall(predict_label, predict_label, actual_label, num_in_class, 'label', 0);
%% average distance matrix
m = length(distance_matrix_diff);
n1 = size(distance_matrix_diff{1, 1}, 1);
n2 = size(distance_matrix_diff{1, 1}, 2);
distance_sum = zeros(n1, n2);
for i = 1:m
    if ~isempty(distance_matrix_diff{1, i})
        distance_sum = distance_sum + distance_matrix_diff{1, i};
    else
        i = i - 1;
        break;
    end
end
distance_table_diff = distance_sum / i;

m = length(distance_matrix_interg);
n1 = size(distance_matrix_interg{1, 1}, 1);
n2 = size(distance_matrix_interg{1, 1}, 2);
distance_sum = zeros(n1, n2);
for i = 1:m
    if ~isempty(distance_matrix_interg{1, i})
        distance_sum = distance_sum + distance_matrix_interg{1, i};
    else
        i = i - 1;
        break;
    end
end
distance_table_interg = distance_sum / i;

%% plot the relative recognition accuracy under different noise level

relative_interg = sort(recog_ratio_interg, 'descend');
relative_interg = relative_interg / relative_interg(1);
relative_diff = sort(recog_ratio_diff, 'descend');
relative_diff = relative_diff / relative_diff(1);
plot(relative_interg, '.b-', 'MarkerSize', 20), hold on; plot(relative_diff, '.r-', 'MarkerSize', 20);
axis([1 6 0.5 1.1]); grid on;
