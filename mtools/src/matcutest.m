function matcutest
%MatCUTEst provides the following functions to facilitate the usage of CUTEst
% ( https://github.com/ralna/CUTEst ) in MATLAB under Linux.
%
% - macup(PROBLEM_NAME) returns a structure containing the full information of the  problem named
%   PROBLEM_NAME (a string). The structure contains the objective function, constraints (if any),
%   starting point, etc.
%
% - decup(PROBLEM_NAME) destroys the problem named PROBLEM_NAME.
%
% - secup(REQUIREMENT) returns a cell array of strings, which are the names of the problems selected
%   according to REQUIREMENT. Here, REQUIREMENT is a structure indicating the requirement on the
%   problems, such as
%     - maxdim: maximal dimension
%     - mindim: minimal dimension
%     - maxcon maximal number of constraints
%     - mincon: minimal number of constraints
%     - type: problem type, which can be 'u' for unconstrained, 'b' for bound-constrained, 'l' for
%       linearly constrained, 'n' for nonlinearly constrained, or a string containing some of 'u',
%       'b', 'l', and 'n'
%     - blacklist: a cell array of strings representing a list of problems to avoid
%
% Try "help macup", "help decup", and "help secup" for more information.
%
% **************************************************************************************************
% ZHANG Zaikun, Hong Kong Polytechnic University, https://zhangzk.net, June 2020, Hong Kong
% **************************************************************************************************
