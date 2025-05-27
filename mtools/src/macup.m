function problem = macup(pname, options)
%MACUP (MAke CUtest Problem) builds a structure containing the information
% of the CUTEst problem specified by pname. The field names of this structure
% are self-explaining, but particular attention may be paid on "objective"
% and "nonlcon", which are explained below.
%
% - objective: The structure contains a handle for the objective function at the field
%   "objective". Its signature is
%
%   [f, gradient, Hessian] = objective(x)
%
% - nonlcon: If the problem has nonlinear constraints, then the structure also contains
%   a handle for the constraint function at the field "nonlcon". Its signature is
%
%     [nlcineq, nlceq, grad_nlcineq, grad_nlceq] = nonlcon(x).
%
%   Following the convention of MATLAB (see
%   https://www.mathworks.com/help/optim/ug/nonlinear-constraints.html ),
%   the nonlinear constraints are nlcineq <= 0 and nlceq = 0,
%   grad_nlcineq is the gradient (i.e., transpose of the Jacobin matrix)
%   of nlcineq, while grad_nlceq is that of nlceq.
%   When there is no nonlinear constraints, the field "nonlcon" is set to [].
%
% Some options can be included. For the current version (20230202), the only
% option is `get_H0`, indicating whether to include the Hessian at x0 in the
% problem structure or not.
%
% N.B.: This is the place where we call CUTEst functions, including
% cutest_setup, cutest_terminate, cutest_obj, and cutest_cons.

cutest_inf = 1e20; % In CUTEst, an upper/lower bound with value 1e20/-1e20 means no bound.

cutest_dir = cutestdir();
% The following path contains `cutest_setup` etc.
addpath(fullfile(cutest_dir,'src', 'matlab'));
% The following path contains the MEX files of CUTEst problems.
mexdir = fullfile(cutest_dir, 'mex');

% remove all the previously added CUTEst paths
path_cell = split(path, ':');
cellfun(@rmpath, path_cell(contains(path_cell, mexdir)));

pname = char(upper(pname));
pmexdir = fullfile(mexdir, pname);
if ~exist(pmexdir, 'dir')
    error('Cannot find the MEX directory of the given problem.');
end

olddir = cd;
cd(pmexdir);  % We must go to the MEX directory of the given problem.

clear('macup_error');
try  % Everything until catch is done in pmexdir.
    try
        cutest_terminate();
    catch
        % do nothing
    end
    prob = cutest_setup();

    x0=prob.x;  % starting point
    [f0, g0] = cutest_obj(x0);
    get_H0 = (nargin >= 2 && isfield(options, 'get_H0') && islogical(options.get_H0) && options.get_H0);
    if get_H0
        H0 = cutest_ihess(x0, 0);  % May be expensive
    end

    bl = prob.bl;  % lower bound
    bl(bl <= -cutest_inf) = -inf;
    bu = prob.bu;  % upper bound
    bu(bu >= cutest_inf) = inf;
    if min([-bl; bu]) == inf
        bl = [];
        bu = [];
    end

    cl = prob.cl;  % lower bound of constraints
    cl(cl <= -cutest_inf) = -inf;
    cu = prob.cu;  % upper bound of constraints
    cu(cu >= cutest_inf) = inf;
    linear = prob.linear;  % an array of true/false indicating whether each constraint is linear or not
    equatn = prob.equatn;  % an array of true/false indicating whether each constraint is an equality or not

    if isempty(bl) && isempty(bu) && isempty(linear)  % unconstrained problem
        ptype = 'u';
    elseif isempty(linear)  % bound constrained problem
        ptype = 'b';
    elseif all(linear)  % linearly (not only bound) constrained problem
        ptype = 'l';
    else  % nonlinearly constrained problem
        ptype = 'n';
    end

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

    if isempty(linear)  % unconstrained or bound constrained problem
        Aeq = [];
        beq = [];
        Aineq = [];
        bineq = [];
        nonlcon = [];
        nlcineq0 = [];
        nlceq0 = [];
        gnlcineq0 = [];
        gnlceq0 = [];
    else
        leq = linear & equatn;  % linear equality constraints
        lineq = linear & ~equatn;  % linear inequality constraints
        nleq = ~linear & equatn;  % nonlinear equality constraints
        nlineq = ~linear & ~equatn;  % nonlinear equality constraints

        [consx0, J] = cutest_cons(x0);  % J is the Jacobian matrix of the constraints other than bounds.
        cons0 = consx0 - J*x0;  % A linear constraint looks like cl <= J*x + cons0 <= cu.
        Aeq = J(leq, :);
        beq = cu(leq) - cons0(leq);
        Aineq = [J(lineq, :); -J(lineq, :)];  % linear constraint: Aineq*x <= bineq
        bineq = [cu(lineq) - cons0(lineq); -cl(lineq) + cons0(lineq)];
        Aineq = Aineq(bineq < inf, :);  % remove the linear constraints with infinite right-hand sides
        bineq = bineq(bineq < inf);

        assert((isempty(Aeq) && isempty(beq)) || (size(Aeq, 1) == numleq && size(Aeq, 2) == length(x0) && length(beq) == numleq));
        assert((isempty(Aineq) && isempty(bineq)) || (size(Aineq, 1) == numlineq && size(Aineq, 2) == length(x0) && length(bineq) == numlineq));

        if all(linear)
            nonlcon = [];  % no nonlinear constraints
            nlcineq0 = [];
            nlceq0 = [];
            gnlcineq0 = [];
            gnlceq0 = [];
        else
            nonlcon = @(x) eval_cutest_nlc(x, @cutest_cons, cl, cu, nlineq, nleq);  % nonlinear constraints: [nlcineq, nlceq] = nonlcon(x), nlcineq <= 0, nlceq = 0
            [nlcineq0, nlceq0, gnlcineq0, gnlceq0] = nonlcon(x0);
        end

        assert(isempty(nlcineq0) || (length(nlcineq0) == numnlineq && size(gnlcineq0, 1) == length(x0) && size(gnlcineq0, 2) == numnlineq));
        assert(isempty(nlceq0) || (length(nlceq0) == numnleq && size(gnlceq0, 1) == length(x0) && size(gnlceq0, 2) == numnleq));
    end
catch macup_error
    % do nothing for now
end

cd(olddir);  % go back to the original directory

if exist('macup_error', 'var')
    rethrow(macup_error);
else
    problem = struct();
    problem.name = pname;
    problem.type = ptype;
    problem.mexdir = pmexdir;
    problem.objective = @(x) eval_cutest_obj(x, @cutest_obj, @cutest_ihess);  % [f, g, H] = problem.objective(x)
    problem.x0 = x0;
    problem.Aineq = Aineq;  % linear constraint: Aineq*x <= bineq
    problem.bineq = bineq;
    problem.Aeq = Aeq;
    problem.beq = beq;
    problem.lb = bl;  % The lower bound for x is called bl in CUTEst, while we use lb as in fmincon.
    problem.ub = bu;
    problem.nonlcon = nonlcon;  % [nlcineq(x), nlceq(x), \nabla nlcineq (x), \nabla nlceq(x)] = problem.nonlcon(x); nonlinear constraints: nlcineq(x) <= 0, nlceq(x) = 0;

    problem.f0 = f0;
    problem.g0 = g0;
    if get_H0
        problem.H0 = H0;  % May be expensive.
    end
    problem.nlcineq0 = nlcineq0;
    problem.nlceq0 = nlceq0;
    problem.gnlcineq0 = gnlcineq0;
    problem.gnlceq0 = gnlceq0;

    problem.constrv0 = 0;
    if ~isempty(bl)
        problem.constrv0 = max([problem.constrv0; bl-x0]);
    end
    if ~isempty(bu)
        problem.constrv0 = max([problem.constrv0; x0-bu]);
    end
    if ~isempty(Aineq)
        problem.constrv0 = max([problem.constrv0; Aineq*x0-bineq]);
    end
    if ~isempty(Aeq)
        problem.constrv0 = max([problem.constrv0; abs(Aeq*x0-beq)]);
    end
    problem.constrv0 = max([problem.constrv0; nlcineq0; abs(nlceq0)]);

    % Information about numbers of constraints
    problem.numb = numb;  % Number of bound constraints
    problem.numlb = numlb;  % Number of lower bound constraints
    problem.numub = numub;  % Number of upper bound constraints
    problem.numfixedx = numfixedx;  % Number of fixed variables
    problem.numcon = numcon;  % Number of constraints excluding the bounds
    problem.numlcon = numlcon;  % Number of linear constraints excluding the bounds
    problem.numnlcon = numnlcon;  % Number of nonlinear constraints
    problem.numeq = numeq;  % Number of equality constraints
    problem.numineq = numineq;  % Number of inequality constraints
    problem.numleq = numleq;  % Number of linear equality constraints
    problem.numlineq = numlineq;  % Number of linear inequality constraints
    problem.numnleq = numnleq;  % Number of nonlinear equality constraints
    problem.numnlineq = numnlineq;  % Number of nonlinear inequality constraints

    addpath(pmexdir); % We must add the MEX directory of the current problem to the path.
end

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Auxiliary Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [nlcineq, nlceq, grad_nlcineq, grad_nlceq] = eval_cutest_nlc(x, cutestcons, cl, cu, nlineq, nleq)
% Nonlinear constraints: nlcineq <= 0, nlceq = 0
% Following the convention of MATLAB (see
% https://www.mathworks.com/help/optim/ug/nonlinear-constraints.html ),
% grad_nlcineq is the gradient (i.e., transpose of the Jacobin matrix)
% of nlcineq, while grad_nlceq is that of nlceq.

% N.B.: Check the `nargout` and calculate only the requested outputs. Important for performance.
% Omitted outputs by ~ are included in `nargout`; e.g., for [~, a, ~] = eval_cutest_obj, nargout = 3.
if nargout <= 2
    con_val = cutestcons(x); % Constraints: cl <= con_val <= cu
else
    [con_val, J] = cutestcons(x); % Constraints: cl <= con_val <= cu
end

nlcineq = [con_val(nlineq); -con_val(nlineq)];
nlbineq = [cu(nlineq); -cl(nlineq)];
nlcineq = nlcineq(nlbineq < inf) - nlbineq(nlbineq < inf);
nlceq = con_val(nleq)-cu(nleq);

if nargout > 2
    grad_nlcineq = [J(nlineq, :)', -J(nlineq, :)'];
    grad_nlcineq = grad_nlcineq(:, nlbineq < inf);
    grad_nlceq = J(nleq, :)';
end

return


function [f, g, H] = eval_cutest_obj(x, cutest_obj, cutest_ihess)
% N.B.: Check the `nargout` and calculate only the requested outputs. Important for performance.
% Omitted outputs by ~ are included in `nargout`; e.g., for [~, a, ~] = eval_cutest_obj, nargout = 3.
if nargout == 1
    f = cutest_obj(x);
else
    [f, g] = cutest_obj(x);
end
if nargout >= 3
    H = cutest_ihess(x, 0);
end
return
