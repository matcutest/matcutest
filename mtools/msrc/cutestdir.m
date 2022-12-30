function cdir = cutestdir()
%CUTESTDIR returns a string that is the directory of CUTEst.
% We expect a Linux system that has an environment variable 'CUTEST'
% indicating the path to the directory of CUTEst.

%[~, cdir] = system('echo $CUTEST');  % path to the directory of CUTEst
%cdir = strtrim(regexprep(cdir, '[\n\r]+', ''));  % the result of echo may contain line breaks

% Here is a portable implementation:
cdir = getenv('CUTEST');
if isempty(cdir)
    error('CUTEstMtools:CUTESTNotSet', 'The environment variable ''CUTEST'' is not set.');
end

return
