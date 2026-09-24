function hbplSetup(dataset)
% HBPLSETUP  Put HBPL and its dependencies on the MATLAB path.
%
%   HBPLSETUP              adds the shared code and third-party toolboxes
%   HBPLSETUP('ntu_rgbd')  additionally adds that dataset's pipeline
%
%   Valid dataset names: 'msr_action3d', 'ut_kinect', 'ntu_rgbd'.
%   Only one dataset should be on the path at a time: the three pipelines
%   deliberately contain same-named files (run.m, GeneFeatsPerBody.m, the
%   cost-function wrappers) whose contents differ per dataset.
%
%   VLFeat also needs its own one-time initialisation, which this does.
%
%   Example
%       hbplSetup('ntu_rgbd')
%       cd src/ntu_rgbd
%       run
%
%   See also HBPLDATADIR.

here = fileparts(mfilename('fullpath'));

addpath(fullfile(here, 'src', 'common'));

% VLFeat and LIBSVM are not distributed with this repository; see README for
% where to get them. Both are expected under third_party/.
vlSetup = fullfile(here, 'third_party', 'vlfeat-0.9.20', 'toolbox', 'vl_setup.m');
if exist(vlSetup, 'file') == 2
    run(vlSetup);                     % registers VLFeat's own toolbox subfolders
else
    warning('hbplSetup:noVLFeat', ...
            ['VLFeat not found under third_party/vlfeat-0.9.20/. ' ...
             'vl_gmm and vl_fisher are required by GeneFisherCodeJointPyramid.']);
end

svmDir = fullfile(here, 'third_party', 'libsvm-3.17', 'matlab');
if exist(svmDir, 'dir') == 7
    addpath(svmDir);
else
    warning('hbplSetup:noLIBSVM', ...
            ['LIBSVM not found under third_party/libsvm-3.17/. ' ...
             'Only the HRRV-SVM baseline needs it; HBPL itself does not.']);
end

if nargin > 0 && ~isempty(dataset)
    valid = {'msr_action3d', 'ut_kinect', 'ntu_rgbd'};
    if ~ismember(dataset, valid)
        error('hbplSetup:unknownDataset', ...
              'Unknown dataset "%s"; expected one of: %s.', ...
              dataset, strjoin(valid, ', '));
    end
    dsDir = fullfile(here, 'src', dataset);
    addpath(dsDir);
    addpath(fullfile(dsDir, 'ToZP'));   % RRV descriptor, differs per dataset
    fprintf('HBPL: path set up for %s\n', dataset);
else
    fprintf('HBPL: shared path set up; call hbplSetup(''<dataset>'') to add a pipeline.\n');
end
