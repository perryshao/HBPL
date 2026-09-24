for act = 1:20

    drawskt(act, act, 7, 7, 1, 1);
    saveas(gcf, ['act' num2str(act)], 'tif');
    close gcf
end
