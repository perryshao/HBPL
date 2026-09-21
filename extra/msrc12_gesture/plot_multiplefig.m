%comparing with figures
open ('D:\Program Files\MATLAB\R2013a\work\MicrosoftGestureEvaluatingCode\PRC_H_AII3.fig');%open the first fig
obj = get(gca,'children');
x1=get(obj, 'xdata');
y1=get(obj, 'ydata');%save the xy data to x1 and y1
close;
area_1 = sum(y1(2:end-1))*0.11;

open ('D:\Program Files\MATLAB\R2013a\work\MicrosoftGestureEvaluatingCode\PRC_AII.fig');%open the second fig
obj = get(gca,'children');
x2=get(obj, 'xdata');
y2=get(obj, 'ydata');%save the xy data to x2 and y2
close;
area_2 = sum(y2(2:end-1))*0.11;

open ('D:\Program Files\MATLAB\R2013a\work\MicrosoftGestureEvaluatingCode\PRC_R.fig');%open the second fig
obj = get(gca,'children');
x3=get(obj, 'xdata');
y3=get(obj, 'ydata');%save the xy data to x2 and y2
close;
area_3 = sum(y3(2:end-1))*0.11;

open ('D:\Program Files\MATLAB\R2013a\work\MicrosoftGestureEvaluatingCode\PRC_6.fig');%open the second fig
obj = get(gca,'children');
x4=get(obj, 'xdata');
y4=get(obj, 'ydata');%save the xy data to x2 and y2
close;
area_4 = sum(y4(2:end-1))*0.11;

open ('D:\Program Files\MATLAB\R2013a\work\MicrosoftGestureEvaluatingCode\PRC_H_MAII.fig');%open the second fig
obj = get(gca,'children');
x5=get(obj, 'xdata');
y5=get(obj, 'ydata');%save the xy data to x2 and y2
close;
area_5 = sum(y5(2:end-1))*0.11;

open ('D:\Program Files\MATLAB\R2013a\work\MicrosoftGestureEvaluatingCode\PRC_MAII.fig');%open the second fig
obj = get(gca,'children');
x6=get(obj, 'xdata');
y6=get(obj, 'ydata');%save the xy data to x2 and y2
close;
area_6 = sum(y6(2:end-1))*0.11;

figure;
plot(x1,y1,'ob-','MarkerSize',8,'LineWidth',2); hold on;%plot
plot(x2,y2,'xg-','MarkerSize',8,'LineWidth',2); hold on;
plot(x5,y5,'sm-','MarkerSize',8,'LineWidth',2); hold on;
plot(x6,y6,'dk-','MarkerSize',8,'LineWidth',2); hold on;
plot(x3,y3,'vr-','MarkerSize',8,'LineWidth',2); hold on;
plot(x4,y4,'*c-','MarkerSize',8,'LineWidth',2); hold on;


grid on;
legend('AII+RD','AII','MAII+RD','MAII','RD','RDSSM');
axis([0 1 0 1]);