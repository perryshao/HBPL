function shuffle_des(marker, shuffle_sort, subjectID_DB, subjectID_SAMPLES)

fileprefix = '_DES.mat';
matfilename_db = [marker fileprefix];
if exist(matfilename_db, 'file')
    load(matfilename_db);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d() funcition');
end

fileprefix = 'samples_DES.mat';
matfilename_samples = [marker fileprefix];
if exist(matfilename_samples, 'file')
    load(matfilename_samples);
else
    fprintf ('Error, there are not existing loaded C3D database, lack of load_c3d_samples() funcition');
end
samples_r = size(TRAJDB_DES, 2);
samples_t = size(TRAJSAMPLES_DES, 2);
tempTRAJDB_DES = cell(1, []);
tempTRAJSAMPLES_DES = cell(1, []);
%% COLLECT TRAIN DESCRIPTOR

for i = 1:samples_r
    if any(shuffle_sort(1, :) == subjectID_DB(i))
        tempTRAJDB_DES{1, end + 1} = TRAJDB_DES{1, i};
    end
end

for i = 1:samples_t
    if any(shuffle_sort(1, :) == subjectID_SAMPLES(i))
        tempTRAJDB_DES{1, end + 1} = TRAJSAMPLES_DES{1, i};
    end
end

%% COLLECT SAMPLES DESCRIPTOR

for i = 1:samples_r
    if any(shuffle_sort(2, :) == subjectID_DB(i))
        tempTRAJSAMPLES_DES{1, end + 1} = TRAJDB_DES{1, i};
    end
end

for i = 1:samples_t
    if any(shuffle_sort(2, :) == subjectID_SAMPLES(i))
        tempTRAJSAMPLES_DES{1, end + 1} = TRAJSAMPLES_DES{1, i};
    end
end
%% save as mat files
TRAJDB_DES = tempTRAJDB_DES;
save(matfilename_db, 'TRAJDB_DES');
TRAJSAMPLES_DES = tempTRAJSAMPLES_DES;
save(matfilename_samples, 'TRAJSAMPLES_DES');
