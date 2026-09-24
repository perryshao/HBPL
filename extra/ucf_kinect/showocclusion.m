m = 50;
hold on;
%% 5 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_5occlu', num2str(i))]);

    % sort the results as occlusion ratio varies from 0-0.4
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9922;

    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_occlu, '-vg');
%% 10 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_10occlu', num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9953;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_occlu, '-xb');
%% 14 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_14occlu', num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9938;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_noise, '-+', 'Color', [0.49, 0.18, 0.50]);
%% 5+10 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_5+10occlu', num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9953;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_occlu, '*-k');
%% 5+14 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_5+14occlu', num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9969;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_occlu, '-sc');
%% 10+14 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_10+14occlu', num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9953;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_occlu, '-dm');
%% 5+10+14 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval(['load ' strcat('occlu_results_cs\test_occlu', num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end - 1)];
    recog_ratio_smml(1) = 0.9969;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu;
end
recog_ratio_occlu = recog_ratio_occlu / m;
plot(recog_ratio_occlu, '-or');

%% set properties of the figure
ylim([0.7 1]);
legend('MBPL(L1)', 'MBPL(L2)', 'MBPL(L3)', 'MBPL(L1+L2)', 'MBPL(L1+L3)', 'MBPL(L2+L3)', 'MBPL(L1+L2+L3)')
set(gca, 'XTick', 1:1:5)
set(gca, 'XTickLabel', {'0', '10%', '20%', '30%', '40%'})
xlabel('Ratio of Occlusion');
