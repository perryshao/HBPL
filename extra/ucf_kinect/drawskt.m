% USAGE: drawskt(1,3,1,4,1,2) --- show actions 1,2,3 performed by subjects 1,2,3,4 with instances 1 and 2.
function drawskt(s1, s2, a1, a2, e1, e2)

J = [1     4     7     5     6    8     9       3     10    13     11    12    14    15
     2     2     2     4     5    7     8       2     3        3     10    11    13    14];

B = [];
for s = s1:s2
    for a = a1:a2
        for e = e1:e2
            file = sprintf('UCFKinectSkeletonReal/data/%02i-a%02i.%01i.ske', s, a, e);
            [X, Y, Z] = readUCFske(file);
        end
    end
end

% l=size(B,1)/4;
% B=reshape(B,4,l);
% B=B';
% B=reshape(B,20,l/20,4);
%
% X=B(:,:,1);
% Z=400-B(:,:,2);
% Y=B(:,:,3)/4;
% P=B(:,:,4);

for s = 1:size(X, 2)
    S = [X(:, s) Y(:, s) Z(:, s)];

    xlim = [0 800];
    ylim = [0 800];
    zlim = [0 800];
    set(gca, 'xlim', xlim, ...
        'ylim', ylim, ...
        'zlim', zlim);

    h = plot3(S(:, 1), S(:, 2), S(:, 3), 'r.');
    % rotate(h,[0 45], -180);
    set(gca, 'DataAspectRatio', [1 1 1])
    %     axis([-1 1 -1 1 -1 1])

    for j = 1:14
        c1 = J(1, j);
        c2 = J(2, j);
        line([S(c1, 1) S(c2, 1)], [S(c1, 2) S(c2, 2)], [S(c1, 3) S(c2, 3)]);
    end

    pause(1 / 20)
end

figure(1);
S = [X(:, 1) Y(:, 1) Z(:, 1)];
joints = plot3(S(:, 1), S(:, 2), S(:, 3), 'rs', 'markersize', 10);

for j = 1:19
    c1 = J(1, j);
    c2 = J(2, j);
    plot3([S(c1, 1) S(c2, 1)], [S(c1, 2) S(c2, 2)], [S(c1, 3) S(c2, 3)], '-rs', 'LineWidth', 2); hold on;
end
S = [X(:, size(X, 2)) Y(:, size(X, 2)) Z(:, size(X, 2))];
joints = plot3(S(:, 1), S(:, 2), S(:, 3), 'rs', 'markersize', 10); hold on;
for j = 1:19
    c1 = J(1, j);
    c2 = J(2, j);
    plot3([S(c1, 1) S(c2, 1)], [S(c1, 2) S(c2, 2)], [S(c1, 3) S(c2, 3)], '-bs', 'LineWidth', 2); hold on;
end
S_begin = [X(:, 1) Y(:, 1) Z(:, 1)];
S_end = [X(:, size(X, 2)) Y(:, size(X, 2)) Z(:, size(X, 2))];

for j = 1:size(X, 2) - 1
    S = [X(:, j) Y(:, j) Z(:, j)]; S_next = [X(:, j + 1) Y(:, j + 1) Z(:, j + 1)];
    for i = 1:20
        axis equal; plot3([S(i, 1) S_next(i, 1)], [S(i, 2) S_next(i, 2)], [S(i, 3) S_next(i, 3)], '-k', 'LineWidth', 1); hold on;
    end
end

class_num = length(unique(trainGID));
for i = 1:class_num
    trajectory = TRAJDB(2, trainGID == i);
    class_len = length(trajectory);
    for j = 1:class_len
        plot3d(trajectory{1, j});
        xlabel('X', 'FontWeight', 'bold'); ylabel('Y', 'FontWeight', 'bold'); zlabel('Z', 'FontWeight', 'bold');
        saveas(gcf, strcat(num2str(i), '-', num2str(j)), 'png')
    end
end
