function [PairDistFeats_DB, PairDistFeats_SAMPLES]  = GenePairDistFeatsBodyJoint(bodyJoints)

%% compare the differences between each pairwise joints for training set
load([bodyJoints{1, end} '.mat']);
samples_r = size(TRAJDB, 2);
JointNum = size(bodyJoints, 1);
PairDistFeats_DB = cell(1, samples_r);

for n = 1:JointNum
    load([bodyJoints{n, end} '.mat']);
    eval([strcat('DB_', bodyJoints{n, end}) '=TRAJDB;']);
end

%% compute the generic frame by averaging all the first frames
TempJointsFrame = zeros(samples_r, 3 * JointNum);
for i = 1:samples_r
    for n = 1:JointNum
        eval(['TempJointsFrame(i,(n-1)*3+1:n*3)=' strcat('DB_', bodyJoints{n, end}) '{2,i}(1,:);']); % the first frame of each joint of each sample
    end
end
genericFrame = mean(TempJointsFrame, 1);
genericFrame = reshape(genericFrame, 3, [])';

%% for training set
for i = 1:samples_r
    fprintf ('get the Pair Distance Descriptors for training data %d/%d...\n', i, samples_r);
    eval(['TempDB=' strcat('DB_', bodyJoints{1, end}) '{2,i};']);
    T = size(TempDB, 1);
    AlljointsPos = zeros(T, 3 * JointNum);
    for n = 1:JointNum
        eval(['AlljointsPosTemp=' strcat('DB_', bodyJoints{n, end}) '{2,i};']);
        AlljointsPos(:, (n - 1) * 3 + 1:n * 3) = AlljointsPosTemp;
    end
    tempDistFeats = zeros(T * JointNum, JointNum * 3 - 1);
    for j = 1:T
        CurrentTD = reshape(AlljointsPos(j, :), 3, [])';
        PairsDs1 = pdist2(CurrentTD, CurrentTD);
        tempDs = [];
        for n = 1:JointNum
            tempDs = [tempDs; PairsDs1(n, [1:n - 1 n + 1:JointNum])];
        end
        PairsDs1 = tempDs;
        if j > 10
            Prev10D = reshape(AlljointsPos(j - 10, :), 3, [])';
        elseif 1 < j && j <= 10
            Prev10D = reshape(AlljointsPos(j - 1, :), 3, [])';
        else
            Prev10D = CurrentTD;
        end
        PairsDs2 = pdist2(CurrentTD, Prev10D);
        if j > 1
            %             PrevOrigD = reshape(AlljointsPos(1,:),3,[])';
            PrevOrigD = genericFrame;
        else
            PrevOrigD = CurrentTD;
        end
        PairsDs3 = pdist2(CurrentTD, PrevOrigD);
        PairsDs = [PairsDs1 PairsDs2 PairsDs3];
        PairsDs = PairsDs ./ repmat(std(PairsDs, 0, 2), 1, JointNum * 3 - 1);
        for n = 1:JointNum
            tempDistFeats((n - 1) * T + j, :) = PairsDs(n, :);
        end
    end
    PairDistFeats_DB{1, i} = tempDistFeats;
end
%% compare the differences between each pairwise joints for test set
load([bodyJoints{1, end} 'samples.mat']);
samples_t = size(TRAJSAMPLES, 2);
JointNum = size(bodyJoints, 1);
PairDistFeats_SAMPLES = cell(1, samples_t);

for n = 1:JointNum
    load([bodyJoints{n, end} 'samples.mat']);
    eval([strcat('SAMPLES_', bodyJoints{n, end}) '=TRAJSAMPLES;']);
end

for i = 1:samples_t
    fprintf ('get the Pair Distance Descriptors for test data %d/%d...\n', i, samples_t);
    eval(['TempSAMPLES=' strcat('SAMPLES_', bodyJoints{1, end}) '{2,i};']);
    T = size(TempSAMPLES, 1);
    AlljointsPos = zeros(T, 3 * JointNum);
    for n = 1:JointNum
        eval(['AlljointsPosTemp=' strcat('SAMPLES_', bodyJoints{n, end}) '{2,i};']);
        AlljointsPos(:, (n - 1) * 3 + 1:n * 3) = AlljointsPosTemp;
    end
    tempDistFeats = zeros(T * JointNum, JointNum * 3 - 1);
    for j = 1:T
        CurrentTD = reshape(AlljointsPos(j, :), 3, [])';
        PairsDs1 = pdist2(CurrentTD, CurrentTD);
        tempDs = [];
        for n = 1:JointNum
            tempDs = [tempDs; PairsDs1(n, [1:n - 1 n + 1:JointNum])];
        end
        PairsDs1 = tempDs;
        if j > 10
            Prev10D = reshape(AlljointsPos(j - 10, :), 3, [])';
        elseif 1 < j && j <= 10
            Prev10D = reshape(AlljointsPos(j - 1, :), 3, [])';
        else
            Prev10D = CurrentTD;
        end
        PairsDs2 = pdist2(CurrentTD, Prev10D);
        if j > 1
            %             PrevOrigD = reshape(AlljointsPos(1,:),3,[])';
            PrevOrigD = genericFrame;
        else
            PrevOrigD = CurrentTD;
        end
        PairsDs3 = pdist2(CurrentTD, PrevOrigD);
        PairsDs = [PairsDs1 PairsDs2 PairsDs3];
        PairsDs = PairsDs ./ repmat(std(PairsDs, 0, 2), 1, JointNum * 3 - 1);
        for n = 1:JointNum
            tempDistFeats((n - 1) * T + j, :) = PairsDs(n, :);
        end
    end
    PairDistFeats_SAMPLES{1, i}  =  tempDistFeats;
end

save PairDistFeats_DB PairDistFeats_DB;
save PairDistFeats_SAMPLES PairDistFeats_SAMPLES;
