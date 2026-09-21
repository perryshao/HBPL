m=5;
hold on;
%% 10 joints 
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_10occlu',num2str(i))]);
    
    % sort the results as occlusion ratio varies from 0-0.4 
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2)];
    recog_ratio_smml(1) = 0.7514; 
    
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-vg');
%% 20 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_20occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2) ];
    recog_ratio_smml(1) = 0.7887; 
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-xb');
%% 38 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_38occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2) ];
    recog_ratio_smml(1) = 0.7949; 
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-+','Color', [0.49,0.18,0.56]);
%% 10+20 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_10+20occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2) ];
    recog_ratio_smml(1) = 0.8067;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'*-k');
%% 10+38 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_10+38occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2) ];
    recog_ratio_smml(1) = 0.8165;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-sc');
%% 20+38 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_20+38occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2) ];
    recog_ratio_smml(1) = 0.8112;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-dm');
%% 10+20+38 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results/test_occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(1) recog_ratio_smml(1:end-2) ];
    recog_ratio_smml(1) = 0.8200;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-or');

%% set properties of the figure
ylim([0.0 1]);
legend('HBPL(L1)','HBPL(L2)','HBPL(L3)','HBPL(L1+L2)','HBPL(L1+L3)','HBPL(L2+L3)','HBPL(L1+L2+L3)')
set(gca,'XTick',1:1:5)  
set(gca,'XTickLabel',{'0','10%','20%','30%','40%'}) 
xlabel('Ratio of Occlusion');  
ylabel('Recognition Accuracy'); 