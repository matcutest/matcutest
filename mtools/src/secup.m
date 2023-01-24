function plist = secup(requirements)
%SECUP (SElect CUtest Problems) selects CUTEst problems that fulfill REQIREMENTS
% REQIREMENTS is a structure with the following fields
% list: an array of strings, indicating a list from which we should select the problems
% blacklist: an array of strings, indicating a list of problems not to select
% type: type of the problems; it is a string containing 'u' (unconstrained),
%       'b' (bound constrained), 'l' (linearly constrained), or 'n' (nonlinearly constrained)
% lower/upper bounds of problem dimension or number of constraints, for example
% mindim: minimal dimension of the problems
% maxdim: maximal dimension of the problems
% minb: minimal number of bound constraints of them problems
% maxb: maximal number of bound constraints of them problems
% mincon: minimal number of constraints (other than bounds) of the problems
% maxcon: maximal number of constraints (other than bounds) of the problems

% Read the requirements
if nargin == 0 || isempty(requirements) || ~isa(requirements, 'struct')
    requirements = struct();
end
if isfield(requirements, 'list')
    list = requirements.list;  % Select problems only from this list
else
    % Even though not mathematically consistent, this means we do not
    % impose any requirement using the list, i.e., the list is the full
    % problem set.
    list = {};
end
if isfield(requirements, 'blacklist')
    blacklist = requirements.blacklist;  % Do not select problems in this list
else
    blacklist = {};
end
if isfield(requirements, 'type')
    type = requirements.type;
else
    type = 'ubln';
end

maxmin_fields = {'dim', 'numb', 'numlb', 'numub', 'numcon', 'numlcon', 'numnlcon', 'numeq', 'numineq', 'numleq', 'numlineq', 'numnleq', 'numnlineq'};

% Revise the blacklist
blacklist = [blacklist, {'A0NNDNDL', 'A0NNDNIL', 'A0NNDNSL', 'A0NNSNSL', 'A0NSDSDL', ...
    'DIAMON3DLS','DIAMON2D', 'DIAMON2DLS','DIAMON3D', 'MNISTS0', ...
    'MNISTS0LS','MNISTS5LS','MNISTS5', 'BA-L16', 'BA-L16LS', 'BA-L52', 'BA-L52LS', ...
    'BA-L73LS', 'CYCLIC3LS', 'KSSLS', 'REPEAT', 'LRA9A', 'LRCOVTYPE'}]; % Cause MATLAB to crash: At line 32 of file cdimen.f90 (unit = 42, file = 'OUTSDIF.d') Fortran runtime error: End of file, Segmentation fault
blacklist = [blacklist, {'A0ENDNDL', 'A0ENDNDL', 'A0ENINDL', 'A0ENSNDL', 'A0ESDNDL',  ...
    'A2ENDNDL', 'A2ENINDL', 'A2ENSNDL', 'A2ESDNDL', 'A2ESINDL', 'A2ESSNDL', 'A5ENDNDL', ...
    'A2ENINDL', 'A5ENINDL', 'A5ENSNDL', 'A5ESDNDL', 'A5ESINDL', 'A0ESINDL', 'A0ESSNDL', 'A5ESSNDL', ...
    'EG3', 'CYCLOOCF', 'CYCLOOCT', 'OPTMASS', 'ROSEPETAL2', 'LOBSTERZ'}];  % Cause GitHub Actions to terminate unexpectedly.
blacklist = [blacklist, {'HS67'}]; % For unknown reason, this 3D problem takes infinite time during `chcup` on GitHub Actions.
blacklist = [blacklist, {'ALLINQP'}]; % The default dimension of this problem is 50000; MACUP('ALLINQP') takes a long time.
blacklist = [blacklist, {'LHAIFAM'}]; % The starting point has NaN constraint values
blacklist = [blacklist, {'GOFFIN'}]; % This linear-equality constrained problem is strange; when lincoa solves it, x becomes so large (up to 10e16) that the constraint values evaluated by Fortran and matlab are substentially different. Seems to be due to rounding error. Not sure.
blacklist = [blacklist, {'ARGLALE', 'ARGLBLE', 'ARGLCLE', 'MODEL', 'NASH'}]; % Problems are infeasible
blacklist = [blacklist, {'LINCONT'}]; % project cannot find a feasible point, neither does quadprog or fmincon
%blacklist = [blacklist, {'BLOWEYA', 'BLOWEYB', 'DTOC3', 'HUES-MOD', 'HUESTIS', 'POWELL20'}]; % Constraints are feasible, but project cannot find a feasible point
%blacklist = [blacklist, {'DEGENQP', 'DEGENQPC', 'FBRAIN2', 'FBRAIN3', 'SPECANNE'}]; % Too many constraints; test takes too much time
%blacklist = [blacklist, 'TARGUS'];  % Take a long time to solve
blacklist = [blacklist, {'GAUSS1LS', 'GAUSS2LS', 'GAUSS3LS', 'MGH17LS', 'MISRA1ALS', 'MISRA1CLS', 'NELSONLS', 'OSBORNEA','RAT43LS'}]; % Classical uobyqa/cobyla suffers from infinite cycling
blacklist = [blacklist, {'DANWOODLS', 'KOEBHELB'}]; % Classical cobyla suffers from infinite cycling
blacklist=[blacklist, {'QCNEW'}];  % f(x) ~= fx due to bad condition
blacklist=[blacklist, {'BLEACHNG'}];  % MEX function crashes
% Problems with at most 500 variables, but MEX file size > 10 M
blacklist=[blacklist, {'CHANDHEU', 'DEGENQP', 'DMN15102', 'DMN15102LS', 'DMN15103', 'DMN15103LS', 'DMN15332', ...
    'DMN15332LS', 'DMN15333', 'DMN15333LS', 'DMN37142', 'DMN37142LS', 'DMN37143', 'DMN37143LS'}];
% Problems with MEX file size > 10 M
blacklist=[blacklist, {'CLEUVEN3', 'CLEUVEN4', 'CLEUVEN5', 'CLEUVEN6', 'EIGENA', 'EIGENACO', 'EIGENALS', 'EIGENAU', ...
    'EIGENB', 'EIGENBCO', 'EIGENBLS', 'EIGENC', 'EIGENCCO', 'EIGENCLS', 'MODBEALE', 'MODBEALENE', ...
    'LUKVLE2', 'LUKVLI2', 'POWELLBC', '10FOLDTR', 'HARKERP2', 'LIPPERT1', 'LIPPERT2', 'READING8', ...
    'A0NNDNDL', 'A0NNDNIL', 'A0NNDNSL', 'A0NNSNSL', 'A0NSDSDL', 'A0NSDSIL', 'A0NSDSSL', 'A0NSSSSL', ...
    'A2NNDNDL', 'A2NNDNIL', 'A2NNDNSL', 'A2NNSNSL', 'A2NSDSDL', 'A2NSDSIL', 'A2NSDSSL', 'A2NSSSSL', ...
    'A5NNDNDL', 'A5NNDNIL', 'A5NNDNSL', 'A5NNSNSL', 'A5NSDSDL', 'A5NSDSIL', 'A5NSDSSL', 'A5NSSSSL', ...
    'BTS4', 'CONT5-QP', 'DEGDIAG', 'GAUSSELM', 'ALLINQP', 'DMN15103', 'DMN15103LS', 'DMN15333', ...
    'DMN15333LS', 'DMN37143', 'DMN37143LS', 'LEUVEN3', 'LEUVEN4', 'LEUVEN5', 'LEUVEN6', 'DMN15102', ...
    'DMN15102LS', 'DMN15332', 'DMN15332LS', 'DMN37142', 'DMN37142LS', 'FERRISDC', 'FIVE20B', ...
    'QPBAND', 'QPNBAND', 'CHANDHEU', 'FIVE20C', 'BA-L49', 'BA-L49LS', 'DEGENQP', 'NET4', 'DEGTRID', ...
    'DEGTRID2', 'KSS', 'BA-L21', 'BA-L21LS', 'NONMSQRT', 'NONMSQRTNE', 'PORTSQP', 'DEGTRIDL', ...
    'PORTSNQP', 'WALL50', 'BA-L73', 'TWOD', 'CYCLIC3', 'GPP', 'LUBRIF', 'LUBRIFC', 'OSCIGRAD', ...
    'OSCIGRNE', 'INDEFM', 'ROSEPETAL', 'PDE1', 'YATP2CLS', 'YATP2CNE', 'YATP2LS', 'YATP2SQ', ...
    'PDE2', 'YATP1CLS', 'YATP1CNE', 'YATP1LS', 'YATP1NE', 'RDW2D51F', 'RDW2D51U', 'RDW2D52B', ...
    'RDW2D52F', 'RDW2D52U', 'BDRY2', 'WALL100', 'TAX213322', 'TAXR213322', 'CHARDIS0', 'CHARDIS1'}];

load(fullfile(cutestdir(), 'probinfo', 'probinfo.mat'), 'probinfo');

plist = {};
for ip = 1 : length(probinfo)
    prob = probinfo{ip};
    selected = (isempty(list) || ismember(upper(prob.name), upper(list))) && ~ismember(upper(prob.name), upper(blacklist)) && contains(lower(type), lower(prob.type));

    for ifield = 1 : length(maxmin_fields)
        field = maxmin_fields{ifield};
        if strcmp(field, 'dim')
            max_field = 'maxdim';
            min_field = 'mindim';
        elseif startsWith(field, 'num')
            max_field = ['max', field(4:end)];
            min_field = ['min', field(4:end)];
        end
        selected = selected && (~isfield(requirements, max_field) || prob.(field) <= requirements.(max_field));
        selected = selected && (~isfield(requirements, min_field) || prob.(field) >= requirements.(min_field));
    end

    if selected
        plist = [plist, {prob.name}];
    end
end

return
