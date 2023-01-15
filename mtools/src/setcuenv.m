function setcuenv()
%SETCUENV sets some environment variables, which are needed ONLY by getcup.m for mexifying the problems.

mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
rootdir = fileparts(fileparts(mdir));  % The root directory of MatCUTEst.

cutest = getpath(fullfile(rootdir, 'cutest'));
mastsif = getpath(fullfile(rootdir, 'sif'));
archdefs = getpath(fullfile(rootdir, 'archdefs'));
sifdecode = getpath(fullfile(rootdir, 'sifdecode'));
mymatlab = getpath(matlabroot());
myarch = 'pc64.lnx.gfo';
mymatlabarch = myarch;

assert(isempty(getenv('CUTEST')) || strcmp(getpath(getenv('CUTEST')), cutest));
setenv('CUTEST', cutest);

assert(isempty(getenv('MASTSIF')) || strcmp(getpath(getenv('MASTSIF')), mastsif));
setenv('MASTSIF', mastsif);

assert(isempty(getenv('ARCHDEFS')) || strcmp(getpath(getenv('ARCHDEFS')), archdefs));
setenv('ARCHDEFS', archdefs);

assert(isempty(getenv('SIFDECODE')) || strcmp(getpath(getenv('SIFDECODE')), sifdecode));
setenv('SIFDECODE', sifdecode);

assert(isempty(getenv('MYMATLAB')) || strcmp(getpath(getenv('MYMATLAB')), mymatlab));
setenv('MYMATLAB', mymatlab);

assert(isempty(getenv('MYARCH')) || strcmp(getenv('MYARCH'), myarch));
setenv('MYARCH', myarch);

assert(isempty(getenv('MYMATLABARCH')) || strcmp(getenv('MYMATLABARCH'), mymatlabarch));
setenv('MYMATLABARCH', mymatlabarch);

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dirpath = getpath(string)
%GETPATH gets the full and trimmed path corresponding to a string, assuming that the string
% represents a directory. If the string does not represent a directory, then dirpath = '';

cpwd = pwd();

dirpath = '';
if exist(string, 'dir')
    exception = [];
    try
        cd(string);
        dirpath = pwd();
    catch exception
        % Do nothing
    end
    if ~isempty(exception)
        dirpath = '';
    end
    cd(cpwd)
end

return
