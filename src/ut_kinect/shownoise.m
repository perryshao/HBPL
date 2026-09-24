m = 50;
hold on;
%% 5 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_5noise', num2str(i))]);

    % add the results when there is no noise
    recog_ratio_smml = [0.94 recog_ratio_smml];

    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '-vg');
%% 10 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_10noise', num2str(i))]);
    recog_ratio_smml = sort(recog_ratio_smml, 'descend');
    recog_ratio_smml = [0.95 recog_ratio_smml];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '-xb');
%% 19 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_19noise', num2str(i))]);
    recog_ratio_smml = sort(recog_ratio_smml, 'descend');
    recog_ratio_smml = [0.94 recog_ratio_smml];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '-+', 'Color', [0.49, 0.18, 0.56]);
%% 5+10 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_5+10noise', num2str(i))]);
    recog_ratio_smml = sort(recog_ratio_smml, 'descend');
    recog_ratio_smml = [0.96 recog_ratio_smml];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '*-k');
%% 5+19 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_5+19noise', num2str(i))]);
    recog_ratio_smml = sort(recog_ratio_smml, 'descend');
    recog_ratio_smml = [0.95 recog_ratio_smml];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '-sc');
%% 10+19 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_10+19noise', num2str(i))]);
    recog_ratio_smml = [0.95 recog_ratio_smml];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '-dm');
%% 5+10+19 joints
recog_ratio_noise = 0;
for i = 1:m
    eval(['load ' strcat('3jointsnoise_0.12_results\test_noise', num2str(i))]);
    recog_ratio_smml = [0.97 recog_ratio_smml];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise;
end
recog_ratio_noise = recog_ratio_noise / m;
plot(recog_ratio_noise, '-or')
%% set properties of the figure
ylim([0.6 1]);
legend('MBPL(L1)', 'MBPL(L2)', 'MBPL(L3)', 'MBPL(L1+L2)', 'MBPL(L1+L3)', 'MBPL(L2+L3)', 'MBPL(L1+L2+L3)')
set(gca, 'XTick', 1:1:7)
set(gca, 'XTickLabel', {'0', '0.02', '0.04', '0.06', '0.08', '0.10', '0.12'})
xlabel('Standard Deviation');
ylabel('Recognition Accuracy');
