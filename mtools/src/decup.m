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
% Get the current path.
olddir = cd();

path_cell = split(path(), ':');
if nargin == 0 || isempty(prob) % remove all the previously added CUTEst paths
    path_cell = path_cell(contains(path_cell, mexdir));
    for ip = 1:length(path_cell)
        pmexdir = path_cell{ip};
        % When this function is called within a `parfor`, `rmpath` will affect only the current worker.
        rmpath(pmexdir);
        try
            cd(pmexdir);
            cutest_terminate();
        catch
            % do nothing
        end
    end
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

    if any(ismember(path_cell, pmexdir))
        % When this function is called within a `parfor`, `rmpath` will affect only the current worker.
        rmpath(pmexdir);
    end
    try
        cd(pmexdir);
        cutest_terminate();
    catch
        % do nothing
    end
end
cd(olddir);

return
