m=50;
hold on;
%% 5 joints 
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_19_results\test_5occlu',num2str(i))]);
    
    % sort the results as occlusion ratio varies from 0-0.4 
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.94;
    
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-vg');
%% 10 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_19_results\test_10occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.95;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-xb');
%% 19 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_19_results\test_19occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.94;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-+','Color', [0.49,0.18,0.56]);
%% 5+10 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_19_results\test_5+10occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.96;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'*-k');
%% 5+19 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_19_results\test_5+19occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.95;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-sc');
%% 10+19 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_19_results\test_10+19occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.95;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-dm');
%% 5+10+19 joints
recog_ratio_occlu = 0;
for i = 1:m
    eval([ 'load ' strcat('occlu_results\test_occlu',num2str(i))]);
    recog_ratio_smml = [recog_ratio_smml(end) recog_ratio_smml(1:end-1) ];
    recog_ratio_smml(1) = 0.97;
    recog_ratio_occlu = recog_ratio_smml + recog_ratio_occlu; 
end
recog_ratio_occlu = recog_ratio_occlu/m;
plot(recog_ratio_occlu,'-or');

%% set properties of the figure
ylim([0.7 1]);
legend('MBPL(L1)','MBPL(L2)','MBPL(L3)','MBPL(L1+L2)','MBPL(L1+L3)','MBPL(L2+L3)','MBPL(L1+L2+L3)')
set(gca,'XTick',1:1:5)  
set(gca,'XTickLabel',{'0','10%','20%','30%','40%'}) 
xlabel('Ratio of Occlusion');
ylabel('Recognition Accuracy');   