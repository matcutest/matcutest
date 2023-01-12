function cdir = cutestdir()
%CUTESTDIR returns a string that is the directory of CUTEst.
% We expect a Linux system that has an environment variable 'CUTEST' indicating the path to the
% wanted directory. Otherwise, the directory should be ../../cutest.

cdir = getenv('CUTEST');
if isempty(cdir)
    mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
    cdir = fullfile(fileparts(fileparts(mdir)), 'cutest');
end

if ~(exist(fullfile(cdir, 'bin'), 'dir') && exist(fullfile(cdir, 'src', 'matlab'), 'dir'))
    error('CUTEstMtools:InvalidCUTEstDir', '%s is not a valid CUTEst directory.\nCheck that the environment variable ''CUTEST'' is correctly set.', cdir);
end

return
