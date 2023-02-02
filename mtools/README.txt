***************************************************************************
ZHANG Zaikun, Hong Kong Polytechnic University, https://zhangzk.net

June 2020, Hong Kong

Thank Dr. Clément W. Royer ( https://www.lamsade.dauphine.fr/~croyer )
for teaching me how to use CUTEst in MATLAB.
***************************************************************************

The package contains a set of tools to facilitate the usage of CUTEst
( https://github.com/ralna/CUTEst ) in MATLAB under Linux.
It provides the following MATLAB functions:

problem = macup(problem_name)  % make a CUTEst problem
decup(problem_name)  % destroy a CUTEst problem
problem_list = secup(requirements)  % select CUTEst problems according to requirements

For example, try

macup('AKIVA')

This should give you a structure containing the full information of problem AKIVA,
including its objective function, constraints (if any), starting point, etc.

Try "help matcutest" in MATLAB for more information.
