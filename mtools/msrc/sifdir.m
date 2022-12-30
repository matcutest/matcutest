function sdir = sifdir()
%SIFDIR returns a string that is the directory containing the SIF files.
% We expect a Linux system that has an environment variable 'MASTSIF'
% indicating the path to the wanted directory.

%[~, sdir] = system('echo $MASTSIF');  % path to the directory
%sdir = strtrim(regexprep(sdir, '[\n\r]+', ''));  % the result of echo may contain line breaks

% Here is a portable implementation:
sdir = getenv('MASTSIF');
if isempty(sdir)
    error('The environment variable ''MASTSIF'' is not set.');
end

return
