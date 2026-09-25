function binaryPath = build_loghog(opencvPrefix, outputDir)
% BUILD_LOGHOG Build the LogHog MEX with OpenCV 4 on macOS or Linux.
%   binaryPath = BUILD_LOGHOG(opencvPrefix, outputDir) expects headers under
%   <opencvPrefix>/include/opencv4 and libraries under <opencvPrefix>/lib.
%   Use a separate output directory; historical binaries are never replaced.
%   Octave uses mkoctfile; MATLAB uses mex and a configured C++ compiler.
%   The MATLAB branch requires validation on the target MATLAB installation.

if nargin ~= 2 || ~ischar(opencvPrefix) || ~ischar(outputDir)
    error('HBPL:buildArguments', 'Supply OpenCV prefix and output directory as character vectors.');
end
if ispc
    error('HBPL:buildPlatform', 'This helper supports macOS/Linux OpenCV library layouts.');
end
includeDir = fullfile(opencvPrefix, 'include', 'opencv4');
libDir = fullfile(opencvPrefix, 'lib');
if exist(fullfile(includeDir, 'opencv2', 'imgproc.hpp'), 'file') ~= 2
    error('HBPL:buildOpenCV', 'OpenCV 4 development headers are missing from %s.', includeDir);
end
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
sourceDir = fullfile(fileparts(mfilename('fullpath')), 'src');
args = {['-I' includeDir], fullfile(sourceDir, 'LogHog.cpp'), ...
        fullfile(sourceDir, 'log_hogcalculator.cpp'), ['-L' libDir], ...
        '-lopencv_imgproc', '-lopencv_core'};
if exist('OCTAVE_VERSION', 'builtin')
    if isunix
        args{end + 1} = ['-Wl,-rpath,' libDir];
    end
    mkoctfile('--mex', args{:}, '-o', fullfile(outputDir, 'LogHog'));
else
    if isunix
        args{end + 1} = ['LDFLAGS=$LDFLAGS -Wl,-rpath,' libDir];
    end
    mex('-largeArrayDims', args{:}, '-outdir', outputDir, '-output', 'LogHog');
end
binaryPath = fullfile(outputDir, ['LogHog.' mexext]);
if exist(binaryPath, 'file') == 0
    error('HBPL:buildMissingOutput', 'The compiler did not produce %s.', binaryPath);
end
fprintf('Built %s\n', binaryPath);
end
