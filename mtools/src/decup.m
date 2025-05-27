function decup(prob)
%DECUP (DEstroy CUtest Problem) destroys a CUTEst problem specified by prob.
% prob can be a string indicating the name of the problem, or
% a structure containing the problem name or the MEX directory of the
% problem. It can also be empty.

cutest_dir = cutestdir();
% The following path contains `cutest_terminate`.
addpath(fullfile(cutest_dir,'src', 'matlab'));
% Find the path to the directories containing the CUTEst MEX files.
mexdir = fullfile(cutest_dir, 'mex');

if nargin == 0 || isempty(prob) % remove all the previously added CUTEst paths
    path_cell = split(path, ':');
    % When this function is called within a `parfor`, `rmpath` will affect only the current worker. 
    cellfun(@rmpath, path_cell(contains(path_cell, mexdir)));
else
    if isa(prob, 'struct')
        if isfield(prob, 'name')
            pmexdir = fullfile(mexdir, char(upper(prob.name)));
        elseif isfield(pname, 'mexdir')
            pmexdir = prob.mexdir;
        else
            error('The given problem is a structure without ''name'' or ''mexdir'' field.');
        end
    elseif isa(prob, 'char') || isa(prob, 'string')
        pmexdir = fullfile(mexdir, char(upper(prob)));
    else
        error('The given problem is neither a structure nor a string.')
    end
    % When this function is called within a `parfor`, `rmpath` will affect only the current worker. 
    rmpath(pmexdir);

    olddir = cd;
    try
        cd(pmexdir);
        cutest_terminate();
    catch
        % do nothing
    end
    cd(olddir);
end

return
