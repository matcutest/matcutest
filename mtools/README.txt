***************************************************************************
ZHANG Zaikun, Hong Kong Polytechnic University, https://zhangzk.net

June 2020, Hong Kong

Thank Dr. Clément W. Royer (https://www.lamsade.dauphine.fr/~croyer) 
for introducing me how to use CUTEst in MATLAB.

The package is released under the GNU General Public License version 3.
***************************************************************************

The package is a set of tools to facilitate the usage of CUTEst
( https://github.com/ralna/CUTEst ) in MATLAB under Linux (maybe also Mac).

How to use?

0. To use this package, one has to first install CUTEst according to 
https://github.com/ralna/CUTEst

1. In MATLAB, execute the 'setup.m' script by executing 

setup 

from the current directory. This will compile (i.e., mexify) all the
CUTEst problems so that they can be used in MATLAB. It may take
a few hours to finish.

2. After 1 is finished, the following functions are available in MATLAB:

problem = macup(problem_name)  % make a CUTEst problem
decup(problem_name)  % destroy a CUTEst problem
problem_list = secup(requirements)  % select CUTEst problems according to requirements
cutest_dir = cutestdir()  % the path to the CUTEst directory

For example, try

macup('AKIVA') 

This should give you a structure containing the full information of problem AKIVA, 
including its objective function, constraints (if any), starting point, etc.
