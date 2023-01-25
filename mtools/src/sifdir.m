function sdir = sifdir()
%SIFDIR returns a string that is the directory containing the SIF files, which should be ../../sif.

mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
sdir = fullfile(fileparts(fileparts(mdir)), 'sif');

if isempty(dir(fullfile(sdir, '*.SIF')))
    error('MatCUTEst:InvalidSIFDir', 'The SIF directory %s does not exist or does not contain any SIF file.\nCheck that the environment variable ''MASTSIF'' is correctly set', sdir);
end

return
