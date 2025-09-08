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
% minb: minimal number of bound constraints of the problems
% maxb: maximal number of bound constraints of the problems
% mincon: minimal number of constraints (other than bounds) of the problems
% maxcon: maximal number of constraints (other than bounds) of the problems
% is_feasibility: true/false, whether the problem should be a feasibility problems (no requirement if not given)

% Read the requirements
if nargin == 0 || isempty(requirements) || ~isa(requirements, 'struct')
    requirements = struct();
end

if isfield(requirements, 'list')
    list = requirements.list;  % Select problems only from this list
else
    % Even though not mathematically consistent, we use list = {} to signify that
    % we do not impose any requirement using the list, i.e., the list is the full
    % problem set.
    list = {};  %
end

if isfield(requirements, 'blacklist')
    blacklist = requirements.blacklist;  % Do not select problems in this list
else
    blacklist = {};
end
blacklist = [blacklist, black_list()];

if isfield(requirements, 'type')
    type = requirements.type;
else
    type = 'ubln';
end

maxmin_fields = {'dim', 'numb', 'numlb', 'numub', 'numcon', 'numlcon', 'numnlcon', 'numeq', 'numineq', 'numleq', 'numlineq', 'numnleq', 'numnlineq', 'numfixedx'};

load(fullfile(cutestdir(), 'probinfo', 'probinfo.mat'), 'probinfo');

np = length(probinfo);
plist = {};
for ip = 1 : np
    prob = probinfo{ip};
    selected = (isempty(list) || ismember(upper(prob.name), upper(list))) && ~ismember(upper(prob.name), upper(blacklist)) && contains(lower(type), lower(prob.type));
    if isfield(requirements, 'is_feasibility') && islogical(requirements.is_feasibility)
        is_feasibility = requirements.is_feasibility;
        selected = selected && ((is_feasibility && prob.is_feasibility) || (~is_feasibility && ~prob.is_feasibility));
    end

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
