function dirPath = hbplDataDir(what)
% HBPLDATADIR  Resolve a data location without hard-coding absolute paths.
%
%   dirPath = HBPLDATADIR('batches')  folder holding the cached per-batch
%                                     feature files traindata<k>.mat and
%                                     testdata<k>.mat
%   dirPath = HBPLDATADIR('raw')      folder holding the raw skeleton files
%
%   Resolution order, first hit wins:
%
%     1. environment variable  HBPL_BATCH_DIR  /  HBPL_RAW_DIR
%     2. <repo>/cache/batches  /  <repo>/data
%
%   Override the cache location without editing the pipeline, e.g.
%
%       setenv('HBPL_BATCH_DIR', '/scratch/ntu/batches')
%
%   This helper creates missing directories; it does not prepare or validate
%   datasets. The pipeline still requires per-joint MAT tables in its current
%   folder, as described in README.md.
%
%   The returned path always ends with a file separator, matching how the
%   original scripts concatenated it.
%
%   Earlier versions of these scripts hard-coded
%   '/home/data/nturgbd_skeletons/...', which is why a clone would not run.
%
%   See also HBPLSETUP.

if nargin < 1
    what = 'batches';
end

repoRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));  % .../HBPL

switch lower(what)
    case 'batches'
        dirPath = getenv('HBPL_BATCH_DIR');
        if isempty(dirPath)
            dirPath = fullfile(repoRoot, 'cache', 'batches');
        end
    case 'raw'
        dirPath = getenv('HBPL_RAW_DIR');
        if isempty(dirPath)
            dirPath = fullfile(repoRoot, 'data');
        end
    otherwise
        error('hbplDataDir:unknownKind', ...
              'Unknown location "%s"; expected ''batches'' or ''raw''.', what);
end

if exist(dirPath, 'dir') ~= 7
    mkdir(dirPath);
end

if dirPath(end) ~= filesep
    dirPath(end + 1) = filesep;
end
