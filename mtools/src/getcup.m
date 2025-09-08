function success = getcup(options)
%GETCUP (GET CUtest Problems) mexify all the CUTEst problems, saving the
% MEX files in cutest_dir/mex and problem information in cutest_dir/probinfo.

% In CUTEst, an upper/lower bound with value 1e20/-1e20 means no bound.
cutest_inf = 1e20;

% Read the options.
if nargin < 1
    options = struct();
end
if isfield(options, 'list')
    list = options.list;
else
    % Even though not mathematically consistent, we use list = {} to signify that
    % we do not impose any requirement using the list, i.e., the list is the full
    % problem set.
    list = {};
end
if isfield(options, 'blacklist')
    blacklist = options.blacklist;
else
    blacklist = black_list();  % The default blacklist.
end

setcuenv();  % set some environment variables needed in the sequel
sif_dir = sifdir();  % path to the directory containing the SIF files
cutest_dir = cutestdir();  % path to the CUTEst directory
% The following path contains `cutest_setup` etc.
addpath(fullfile(cutest_dir,'src', 'matlab'));
mexdir = fullfile(cutest_dir, 'mex');  % the directory that will contain the MEX files
probinfodir = fullfile(cutest_dir, 'probinfo');  % the directory that will contain the problem information files
if (~exist(mexdir, 'dir') && mkdir(mexdir) ~= 1) || (~exist(probinfodir, 'dir') && mkdir(probinfodir) ~= 1)
    error('MatCUTEst:FailToCreateDirectory', 'Failed to create %s or %s.', mexdir, probinfodir);
end

% `c2m` is the command for generating the MEX files; do not use strcat, which will ignore the tailing space
c2m = [cutest_dir, '/bin/cutest2matlab '];

% `probinfo*` are the files that will record the problem information
probinfomat = fullfile(probinfodir, 'probinfo.mat');
probinfotxt = fullfile(probinfodir, 'probinfo.txt');
probinfotex = fullfile(probinfodir, 'probinfo.tex');
problist = fullfile(probinfodir, 'problist');
txtid = fopen(probinfotxt, 'wt');
texid = fopen(probinfotex, 'wt');
listid = fopen(problist, 'wt');
if txtid == -1 || texid == -1 || listid == -1
    error('MatCUTEst:FailToOpenFile', 'Failed to open probinfo.txt, probinfo.tex, or problist.');
end
fprintf(txtid, 'name\ttype\tdim\t#bound\t#lbound\t#ubound\t#fixedx\t#constr\t#lin constr\t#nonlin constr\t#eq constr\t#ineq constr\t#lin eq constr\t#lin ineq constr\t#nonlin eq constr\t#nonlin ineq constr\tis_feasibility\tfbest\n');
fprintf(texid, 'name & type & dim & \\#bound & \\#lbound & \\#ubound & \\#fixedx & \\#constr & \\#lin constr & \\#nonlin constr & \\#eq constr & \\#ineq constr & \\#lin eq constr & \\#lin ineq constr & \\#nonlin eq constr & \\#nonlin ineq constr & is_feasibility & fbest\\\\\n');

% Information about the sif files, which define the problems
sif_cell= dir(fullfile(sif_dir, '*.SIF'));
if isempty(sif_cell)
    error('MatCUTEst:InvalidSIFDir', 'The SIF directory\n\n%s\n\ndoes not exist or does not contain any SIF file.', sif_dir);
end
sif_folders = {sif_cell.folder};  % `sif_folders` should be a cell array with all entries being `sif_dir`.
sif_names = {sif_cell.name};
nsif = length(sif_names);

% `compile` is a logical array indicating whether the corresponding problem will be mexified. It
% will be defined within the loop below.
compile = false(nsif, 1);

olddir = cd;

tic;

clear('getcu_error');
try
    fprintf('\nMexifying the test problems, which may take a few hours ... \n\n');
    % Due to the file writing in `c2m`, this part cannot be parallelized.
    for iprob = 1:nsif
        name = strrep(upper(sif_names{iprob}), '.SIF','');  % Problem name according to the SIF file

        % Decide whether to mexify this problem.
        compile(iprob) = (ismember(name, list) || isempty(list)) && ~ismember(name, blacklist);

        if compile(iprob)
            fprintf('%d. %s\n', iprob, name);
        else
            fprintf('%d. %s --- SKIPPED\n', iprob, name);
            continue;
        end

        probdir = fullfile(mexdir, name);
        if ~exist(probdir, 'dir') && mkdir(probdir) ~= 1
            error('MatCUTEst:FailToCreateDirectory', 'Failed to create %s.', probdir);
        end

        cd(probdir); % Note that everything below is conducted in probdir
        system([c2m, fullfile(sif_folders{iprob}, sif_names{iprob}), ' >> /dev/null']);  % create the MEX file for the problem corresponding to sif_names{iprob}
    end

    fprintf('\nRecording the information of the test problems into a .mat file ... \n\n');
    probinfo = cell(nsif, 1);
    parfor iprob = 1 : nsif
        if ~compile(iprob)
            continue
        end

        name = strrep(upper(sif_names{iprob}), '.SIF','');  % Problem name according to the SIF file
        fprintf('%d. %s\n', iprob, name);

        probdir = fullfile(mexdir, name);
        cd(probdir); % Note that everything below is conducted in probdir

        prob = cutest_setup();

        % Check whether the objective is a constant function, and the problem is thus a feasibility problem.
        is_feasibility = is_constant(@cutest_obj, prob.x, 100);

        cutest_terminate();  % cutest_obj etc. are not needed anymore

        name_mex=strtrim(prob.name); % Problem name according to the MEX file
        assert(strcmpi(name_mex, name), 'MatCUTEst:InvalidProbName', 'The problem name does not match the SIF name.');

        n= prob.n; % Problem dimension
        bl = prob.bl;
        bu = prob.bu;
        bl (bl <= -cutest_inf) = -inf;
        bu (bu >= cutest_inf) = inf;

        % Compute several numbers with names starting with 'num'
        nums = numcup(prob);
        numlb = nums.numlb;
        numub = nums.numub;
        numb = nums.numb;
        numfixedx = nums.numfixedx;
        numcon = nums.numcon;
        numlcon = nums.numlcon;
        numnlcon = nums.numnlcon;
        numeq = nums.numeq;
        numineq = nums.numineq;
        numleq = nums.numleq;
        numlineq = nums.numlineq;
        numnleq = nums.numnleq;
        numnlineq = nums.numnlineq;

        if (min([-bl; bu]) == inf && isempty(prob.linear)) % unconstrained problem
            type = 'u';
        elseif (isempty(prob.linear)) % bound constrained problem
            type = 'b';
        elseif (nnz(prob.linear) == length(prob.linear)) % linearly (not only bound) constrained problem
            type = 'l';
        else % nonlinearly constrained problem
            type = 'n';
        end

        fbest = NaN; % Best know function value. This value maybe be changed by other scripts later.

        % Define a structure to record the information extracted above.
        probinfo{iprob} = struct();
        probinfo{iprob}.name = name;
        probinfo{iprob}.type = type;
        probinfo{iprob}.dim = n; % Different from CUTEst, we use dim instead of n to denote the dimension
        probinfo{iprob}.numb = numb;
        probinfo{iprob}.numlb = numlb;
        probinfo{iprob}.numub = numub;
        probinfo{iprob}.numfixedx = numfixedx;
        probinfo{iprob}.numcon = numcon;
        probinfo{iprob}.numlcon = numlcon;
        probinfo{iprob}.numnlcon = numnlcon;
        probinfo{iprob}.numeq = numeq;
        probinfo{iprob}.numineq = numineq;
        probinfo{iprob}.numleq = numleq;
        probinfo{iprob}.numlineq = numlineq;
        probinfo{iprob}.numnleq = numnleq;
        probinfo{iprob}.numnlineq = numnlineq;
        probinfo{iprob}.is_feasibility = is_feasibility;
        probinfo{iprob}.fbest = fbest;
    end
    % Keep only the components of probinfo corresponding to the compiled problems.
    probinfo = probinfo(compile);

    fprintf('\nRecording the information of the test problems into plain text files ... \n\n');
    nprob = length(probinfo);
    for iprob = 1 : nprob

        % Record the problem name in problist
        fprintf(listid, '%s', probinfo{iprob}.name);
        if iprob < nprob
            fprintf(listid, '\n');
        end

        % Record the problem information in probinfo.txt
        fprintf(txtid,'%s\t', probinfo{iprob}.name);
        fprintf(txtid,'%s\t', probinfo{iprob}.type);
        fprintf(txtid,'%d\t', probinfo{iprob}.dim);
        fprintf(txtid,'%d\t', probinfo{iprob}.numb);
        fprintf(txtid,'%d\t', probinfo{iprob}.numlb);
        fprintf(txtid,'%d\t', probinfo{iprob}.numub);
        fprintf(txtid,'%d\t', probinfo{iprob}.numfixedx);
        fprintf(txtid,'%d\t', probinfo{iprob}.numcon);
        fprintf(txtid,'%d\t', probinfo{iprob}.numlcon);
        fprintf(txtid,'%d\t', probinfo{iprob}.numnlcon);
        fprintf(txtid,'%d\t', probinfo{iprob}.numeq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numineq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numleq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numlineq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numnleq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numnlineq);
        fprintf(txtid,'%d\t', probinfo{iprob}.is_feasibility);
        fprintf(txtid, '%.18e\n', probinfo{iprob}.fbest);

        % Record the problem information in probinfo.tex
        fprintf(texid,'%s & ', probinfo{iprob}.name);
        fprintf(texid,'%s & ', probinfo{iprob}.type);
        fprintf(texid,'%d & ', probinfo{iprob}.dim);
        fprintf(texid,'%d & ', probinfo{iprob}.numb);
        fprintf(texid,'%d & ', probinfo{iprob}.numlb);
        fprintf(texid,'%d & ', probinfo{iprob}.numub);
        fprintf(texid,'%d & ', probinfo{iprob}.numfixedx);
        fprintf(texid,'%d & ', probinfo{iprob}.numcon);
        fprintf(texid,'%d & ', probinfo{iprob}.numlcon);
        fprintf(texid,'%d & ', probinfo{iprob}.numnlcon);
        fprintf(texid,'%d & ', probinfo{iprob}.numeq);
        fprintf(texid,'%d & ', probinfo{iprob}.numineq);
        fprintf(texid,'%d & ', probinfo{iprob}.numleq);
        fprintf(texid,'%d & ', probinfo{iprob}.numlineq);
        fprintf(texid,'%d & ', probinfo{iprob}.numnleq);
        fprintf(texid,'%d & ', probinfo{iprob}.numnlineq);
        fprintf(texid,'%d & ', probinfo{iprob}.is_feasibility);
        fprintf(texid, '%.18e \\\\\n', probinfo{iprob}.fbest);
    end
catch getcu_error
    % do nothing for now
end

cd(olddir);
fclose(txtid);
fclose(texid);
fclose(listid);

if exist('getcu_error', 'var')
    rethrow(getcu_error);
else
    success = true;
    save(probinfomat, 'probinfo');
end

fprintf('\n');
toc;
fprintf('\n');

return
