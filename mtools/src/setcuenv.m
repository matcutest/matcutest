function setcuenv()
%SETCUENV sets some environment variables, which are needed only by getcup.m for mexifying the problems.

mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
rootdir = fileparts(fileparts(mdir));  % The root directory of MatCUTEst.

setenv('CUTEST', fullfile(rootdir, 'cutest'));
setenv('MASTSIF', fullfile(rootdir, 'sif'));
setenv('ARCHDEFS', fullfile(rootdir, 'archdefs'));
setenv('SIFDECODE', fullfile(rootdir, 'sifdecode'));
setenv('MYMATLAB', matlabroot());
setenv('MYARCH', 'pc64.lnx.gfo');
setenv('MYMATLABARCH', 'pc64.lnx.gfo');

return
