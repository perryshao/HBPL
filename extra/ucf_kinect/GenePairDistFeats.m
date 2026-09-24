function [PairDistFeats_DB, PairDistFeats_SAMPLES]  = GenePairDistFeats(joints_no)

%% compare the differences between each pairwise joints for training set
load([joints_no{1, 1} '.mat']);
samples_r = size(TRAJDB, 2);
JointNum = size(joints_no, 1);
PairDistFeats_DB = cell(1, samples_r);

for n = 1:JointNum
    load([joints_no{n, 1} '.mat']);
    eval([strcat('DB_', joints_no{n, 1}) '=TRAJDB;']);
end

TempJointsFrame = zeros(samples_r, 3 * JointNum);
for i = 1:samples_r
    for n = 1:JointNum
        eval(['TempJointsFrame(i,(n-1)*3+1:n*3)=' strcat('DB_', joints_no{n, 1}) '{2,i}(1,:);']); % the first frame of each joint of each sample
    end
end
genericFrame = mean(TempJointsFrame, 1);
genericFrame = reshape(genericFrame, 3, [])';

for i = 1:samples_r
    fprintf ('get the Pair Distance Descriptors for training data %d/%d...\n', i, samples_r);
    eval(['TempDB=' strcat('DB_', joints_no{1, 1}) '{2,i};']);
    T = size(TempDB, 1);
    AlljointsPos = zeros(T, 3 * JointNum);
    for n = 1:JointNum
        eval(['AlljointsPosTemp=' strcat('DB_', joints_no{n, 1}) '{2,i};']);
        AlljointsPos(:, (n - 1) * 3 + 1:n * 3) = AlljointsPosTemp;
    end
    for j = 1:T
        CurrentTD = reshape(AlljointsPos(j, :), 3, [])';
        PairDM = pdist2(CurrentTD, CurrentTD);
        PairsDs1 = PairDM(tril(PairDM, -1) ~= 0);
        if j > 10
            Prev10D = reshape(AlljointsPos(j - 10, :), 3, [])';
        elseif 1 < j && j <= 10
            Prev10D = reshape(AlljointsPos(j - 1, :), 3, [])';
        else
            Prev10D = CurrentTD;
        end
        PairDM = pdist2(CurrentTD, Prev10D);
        PairsDs2 = reshape(PairDM', [], 1);
        if j > 1
            % PrevOrigD = reshape(AlljointsPos(j-1,:),3,[])';
            PrevOrigD = genericFrame;
        else
            PrevOrigD = CurrentTD;
        end
        PairDM = pdist2(CurrentTD, PrevOrigD);
        PairsDs3 = reshape(PairDM', [], 1);
        PairDistFeats_DB{1, i}(j, :) =  ([PairsDs1; PairsDs2; PairsDs3])' / std([PairsDs1; PairsDs2; PairsDs3]);
    end
end
%% compare the differences between each pairwise joints for test set
load([joints_no{1, 1} 'samples.mat']);
samples_t = size(TRAJSAMPLES, 2);
JointNum = size(joints_no, 1);
PairDistFeats_SAMPLES = cell(1, samples_t);

for n = 1:JointNum
    load([joints_no{n, 1} 'samples.mat']);
    eval([strcat('SAMPLES_', joints_no{n, 1}) '=TRAJSAMPLES;']);
end

for i = 1:samples_t
    fprintf ('get the Pair Distance Descriptors for test data %d/%d...\n', i, samples_t);
    eval(['TempSAMPLES=' strcat('SAMPLES_', joints_no{1, 1}) '{2,i};']);
    T = size(TempSAMPLES, 1);
    AlljointsPos = zeros(T, 3 * JointNum);
    for n = 1:JointNum
        eval(['AlljointsPosTemp=' strcat('SAMPLES_', joints_no{n, 1}) '{2,i};']);
        AlljointsPos(:, (n - 1) * 3 + 1:n * 3) = AlljointsPosTemp;
    end
    for j = 1:T
        CurrentTD = reshape(AlljointsPos(j, :), 3, [])';
        PairDM = pdist2(CurrentTD, CurrentTD);
        PairsDs1 = PairDM(tril(PairDM, -1) ~= 0);
        if j > 10
            Prev10D = reshape(AlljointsPos(j - 10, :), 3, [])';
        elseif 1 < j && j <= 10
            Prev10D = reshape(AlljointsPos(j - 1, :), 3, [])';
        else
            Prev10D = CurrentTD;
        end
        PairDM = pdist2(CurrentTD, Prev10D);
        PairsDs2 = reshape(PairDM', [], 1);
        if j > 1
            % PrevOrigD = reshape(AlljointsPos(j-1,:),3,[])';
            PrevOrigD = genericFrame;
        else
            PrevOrigD = CurrentTD;
        end
        PairDM = pdist2(CurrentTD, PrevOrigD);
        PairsDs3 = reshape(PairDM', [], 1);
        PairDistFeats_SAMPLES{1, i}(j, :)  =  ([PairsDs1; PairsDs2; PairsDs3])' / std([PairsDs1; PairsDs2; PairsDs3]);
    end
end

save PairDistFeats_DB PairDistFeats_DB;
save PairDistFeats_SAMPLES PairDistFeats_SAMPLES;
