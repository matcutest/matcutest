function sdir = sifdir()
%SIFDIR returns a string that is the directory containing the SIF files.
% We expect a Linux system that has an environment variable 'MASTSIF' indicating the path to the
% wanted directory. Otherwise, the directory should be ../../sif.

sdir = getenv('MASTSIF');
if isempty(sdir)
    mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
    sdir = fullfile(fileparts(fileparts(mdir)), 'sif');
end

if isempty(dir(fullfile(sdir, '*.SIF')))
    error('CUTEstMtools:InvalidSIFDir', 'The SIF directory %s does not exist or does not contain any SIF file.\nCheck that the environment variable ''MASTSIF'' is correctly set', sdir);
end

return
