function success = getcup()
%GETCUP (GET CUtest Problems) mexify all the CUTEst problems, save the
% MEX files in cutest_dir/mex and problem information in cutest_dir/probinfo.

cutest_inf = 1e20; % In CUTEst, an upper/lower bound with value 1e20/-1e20 means no bound.

sif_dir = sifdir();  % path to the directory containing the SIF files
cutest_dir = cutestdir();  % path to the CUTEst directory
% The following path contains `cutest_setup` etc.
addpath(fullfile(cutest_dir,'src', 'matlab'));

% Define `c2m`, the command for generating the MEX files; do not use strcat, which will ignore the tailing space
c2m = [cutest_dir, '/bin/cutest2matlab '];

mexdir = fullfile(cutest_dir, 'mex');  % the directory that will contain the MEX files
probinfodir = fullfile(cutest_dir, 'probinfo');  % the directory that will contain the problem information files
if (~exist(mexdir, 'dir') && mkdir(mexdir) ~= 1) || (~exist(probinfodir, 'dir') && mkdir(probinfodir) ~= 1)
    error('Failed to create %s or %s.', mexdir, probinfodir);
end

probinfomat = fullfile(probinfodir, 'probinfo.mat');
probinfotxt = fullfile(probinfodir, 'probinfo.txt');
probinfotex = fullfile(probinfodir, 'probinfo.tex');
problist = fullfile(probinfodir, 'problist');
txtid = fopen(probinfotxt, 'wt');
texid = fopen(probinfotex, 'wt');
listid = fopen(problist, 'wt');
if txtid == -1 || texid == -1 || listid == -1
    error('Failed to open probinfo.txt, probinfo.tex, or problist.');
end

fprintf(txtid, 'name\ttype\tdim\t#bound\t#lbound\t#ubound\t#constr\t#lin constr\t#nonlin constr\t#eq constr\t#ineq constr\t#lin eq constr\t#lin ineq constr\t#nonlin eq constr\t#nonlin ineq constr\tfbest\n');
fprintf(texid, 'name & type & dim & \\#bound & \\#lbound & \\#ubound & \\#constr & \\#lin constr & \\#nonlin constr & \\#eq constr & \\#ineq constr & \\#lin eq constr & \\#lin ineq constr & \\#nonlin eq constr & \\#nonlin ineq constr & fbest\\\\\n');

sif_cell= dir(fullfile(sif_dir, '*.SIF'));

if isempty(sif_cell)
    error('The SIF directory %s does not exist or does not contain any SIF file.', sif_dir);
end

sif_cell = {sif_cell.name};
probinfo = cell(length(sif_cell), 1);

olddir = cd;

fprintf('\nMexifying the test problems, which may take a few hours ... \n\n');

tic;

clear('getcu_error');
try
    for iprob = 1 : length(sif_cell)
        probdir = fullfile(mexdir, strrep(sif_cell{iprob}, '.SIF',''));
        if ~exist(probdir, 'dir') && mkdir(probdir) ~= 1
            error('Failed to create %s.', probdir);
        end
        cd(probdir); % Note that everything below is conducted in probdir
        system([c2m, fullfile(sif_dir, upper(sif_cell{iprob})), ' >> /dev/null']);  % create the MEX file for the problem corresponding to sif_cell{iprob}
        prob = cutest_setup();
        cutest_terminate();

        name=strtrim(prob.name); % Problem name
        fprintf(listid, '%s', prob.name);
        if iprob < length(sif_cell)
            fprintf(listid, '\n');
        end
        fprintf('%d. %s\n', iprob, name);

        n= prob.n; % Problem dimension
        bl = prob.bl;
        bu = prob.bu;
        bl (bl <= -cutest_inf) = -inf;
        bu (bu >= cutest_inf) = inf;

        numb = sum(-bl < inf) + sum(bu < inf); % Number of bound constraints
        numlb = sum(-bl < inf);  % Number of lower bound constraints
        numub = sum(bu < inf);  % Number of upper bound constraints
        numcon = length(prob.linear); % Number of constraints other than bounds
        numlcon = sum(prob.linear); % Number of linear constraints other than bounds
        numnlcon = numcon - numlcon; % Number of nonlinear constraints
        numeq = sum(prob.equatn); % Number of equality constraints
        numineq = length(prob.equatn) - numeq; % Number of inequality constraints
        numleq = sum(prob.linear & prob.equatn); % Number of linear equality constraints
        numlineq = numlcon - numleq; % Number of linear inequality constraints
        numnleq = sum(~prob.linear & prob.equatn); % Number of nonlinear equality constraints
        numnlineq = numnlcon - numnleq; % Number of nonlinear inequality constraints

        if (numb > 2*n || numb ~= numlb + numub)
            fprintf('Error: numb > 2*n or numb ~= numlb + numub !\n')
            keyboard
        end
        if (numeq + numineq ~= numcon)
            fprintf('Error: numeq + inequality ~= numcon !\n');
            keyboard
        end
        if (numleq + numnleq ~= numeq || numlineq + numnlineq ~= numineq)
            fprintf('Error: numleq + numnleq ~= numeq or numlineq + numnlineq ~= ineqco !\n');
            keyboard
        end
        if (length(prob.cu) ~= numcon || length(prob.cl) ~= numcon)
            fprintf('Error: length(prob.cu) ~= numcon or length(prob.cl) ~= numcon !\n');
            keyboard
        end

        if (min([-bl; bu]) == inf && isempty(prob.linear)) % unconstrained problem
            type = 'u';
        elseif (isempty(prob.linear)) % bound constrained problem
            type = 'b';
        elseif (sum(prob.linear) == length(prob.linear)) % linearly (not only bound) constrained problem
            type = 'l';
        else % nonlinearly constrained problem
            type = 'n';
        end

        fbest = NaN; % Best know function value. This value maybe be changed by other scripts later.

        % Define a structure to record the information extracted above.
        probinfo{iprob} = [];
        probinfo{iprob}.name = name;
        probinfo{iprob}.type = type;
        probinfo{iprob}.dim = n; % Different from CUTEst, we use dim instead of n to denote the dimension
        probinfo{iprob}.numb = numb;
        probinfo{iprob}.numlb = numlb;
        probinfo{iprob}.numub = numub;
        probinfo{iprob}.numcon = numcon;
        probinfo{iprob}.numlcon = numlcon;
        probinfo{iprob}.numnlcon = numnlcon;
        probinfo{iprob}.numeq = numeq;
        probinfo{iprob}.numineq = numineq;
        probinfo{iprob}.numleq = numleq;
        probinfo{iprob}.numlineq = numlineq;
        probinfo{iprob}.numnleq = numnleq;
        probinfo{iprob}.numnlineq = numnlineq;
        probinfo{iprob}.fbest = fbest;

        % Record the above information in probinfo.txt
        fprintf(txtid,'%s\t', probinfo{iprob}.name);
        fprintf(txtid,'%s\t', probinfo{iprob}.type);
        fprintf(txtid,'%d\t', probinfo{iprob}.dim);
        fprintf(txtid,'%d\t', probinfo{iprob}.numb);
        fprintf(txtid,'%d\t', probinfo{iprob}.numlb);
        fprintf(txtid,'%d\t', probinfo{iprob}.numub);
        fprintf(txtid,'%d\t', probinfo{iprob}.numcon);
        fprintf(txtid,'%d\t', probinfo{iprob}.numlcon);
        fprintf(txtid,'%d\t', probinfo{iprob}.numnlcon);
        fprintf(txtid,'%d\t', probinfo{iprob}.numeq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numineq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numleq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numlineq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numnleq);
        fprintf(txtid,'%d\t', probinfo{iprob}.numnlineq);
        fprintf(txtid, '%.18e\n', probinfo{iprob}.fbest);

        % Record the above information in probinfo.tex
        fprintf(texid,'%s & ', probinfo{iprob}.name);
        fprintf(texid,'%s & ', probinfo{iprob}.type);
        fprintf(texid,'%d & ', probinfo{iprob}.dim);
        fprintf(texid,'%d & ', probinfo{iprob}.numb);
        fprintf(texid,'%d & ', probinfo{iprob}.numlb);
        fprintf(texid,'%d & ', probinfo{iprob}.numub);
        fprintf(texid,'%d & ', probinfo{iprob}.numcon);
        fprintf(texid,'%d & ', probinfo{iprob}.numlcon);
        fprintf(texid,'%d & ', probinfo{iprob}.numnlcon);
        fprintf(texid,'%d & ', probinfo{iprob}.numeq);
        fprintf(texid,'%d & ', probinfo{iprob}.numineq);
        fprintf(texid,'%d & ', probinfo{iprob}.numleq);
        fprintf(texid,'%d & ', probinfo{iprob}.numlineq);
        fprintf(texid,'%d & ', probinfo{iprob}.numnleq);
        fprintf(texid,'%d & ', probinfo{iprob}.numnlineq);
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
