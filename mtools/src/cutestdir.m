function cdir = cutestdir()
%CUTESTDIR returns a string that is the directory of CUTEst, which should be ../../cutest.

mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
cdir = fullfile(fileparts(fileparts(mdir)), 'cutest');

if ~(exist(fullfile(cdir, 'bin'), 'dir') && exist(fullfile(cdir, 'src', 'matlab'), 'dir'))
    error('CUTEstMtools:InvalidCUTEstDir', '%s is not a valid CUTEst directory.\nCheck that the environment variable ''CUTEST'' is correctly set.', cdir);
end

return
