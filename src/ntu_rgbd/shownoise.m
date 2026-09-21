m=5;
hold on;
%% 10 joints 
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_10noise',num2str(i))]);
    
    % add the results when there is no noise
    recog_ratio_smml = [0.7514 recog_ratio_smml(1:end)];
   
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'-vg');
%% 20 joints
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_20noise',num2str(i))]);
    recog_ratio_smml = [0.7887 recog_ratio_smml(1:end)];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'-xb');
%% 38 joints
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_38noise',num2str(i))]);
    recog_ratio_smml = [0.7949 recog_ratio_smml(1:end)];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'-+','Color', [0.49,0.18,0.56]);
%% 10+20 joints
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_10+20noise',num2str(i))]);
    recog_ratio_smml = [0.8067 recog_ratio_smml(1:end)];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'*-k');
%% 10+38 joints
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_10+38noise',num2str(i))]);
    recog_ratio_smml = [0.8165 recog_ratio_smml(1:end)];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'-sc');
%% 20+38 joints
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_20+38noise',num2str(i))]);
    recog_ratio_smml = [0.8112 recog_ratio_smml(1:end)];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'-dm');
%% 10+20+38 joints
recog_ratio_noise = 0;
for i = 1:m
    eval([ 'load ' strcat('3jointsnoise_results/test_noise',num2str(i))]);
    recog_ratio_smml = [0.8200 recog_ratio_smml(1:end)];
    recog_ratio_noise = recog_ratio_smml + recog_ratio_noise; 
end
recog_ratio_noise = recog_ratio_noise/m;
plot(recog_ratio_noise,'-or');

%% set properties of the figure
ylim([0.5 1]);
legend('HBPL(L1)','HBPL(L2)','HBPL(L3)','HBPL(L1+L2)','HBPL(L1+L3)','HBPL(L2+L3)','HBPL(L1+L2+L3)')
set(gca,'XTick',1:1:7)  
set(gca,'XTickLabel',{'0','0.02','0.04','0.06','0.08','0.10','0.12'}) 
xlabel('Standard Deviation');  
ylabel('Recognition Accuracy'); 