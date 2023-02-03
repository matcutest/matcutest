function badlist = chcup(plist, minip, nr)
%CHCUP (CHeck CUtest Problems) checks whether the CUTEst problems in PLIST work without failures,
% starting from PLIST{IP}. It tries making the problem and then evaluating the objective and
% constraint (if any) functions at NR points.
%
% What is MINIP for? If MATLAB crashes when checking problem IP, which did happen several times, we
% then add PLIST{IP} to black_list.m and then run CHCUP again with MINIP = IP, until all problems
% are checked.

if nargin <= 0
    plist = secup();
else
    if ischar(plist) || isstring(plist)
        plist = {plist};
    end
end

if nargin <= 1
    minip = 1;
end

if nargin <= 2
    nr = 10;
end

np = length(plist);
isbad = false(np, 1);

t0 = tic;

% N.B.: parfor will not work; workers will be killed due to excessive resources consumed by some
% large problems, and then mcutest will complain about "incorrect size of input" when checking other
% problems for unknown reasons.
for ip = minip : np
    pname = plist{ip};
    fprintf("%4d. %s\t", ip, pname);

    try
        fprintf("macup");
        tstart = tic;
        p = macup(pname);
        tmacup = toc(tstart);
        fprintf("\t%g\t", 100*tmacup);

        x0 = p.x0;
        objective = p.objective;
        nonlcon = p.nonlcon;

        tstart = tic;
        for ir = 1 : nr
           fprintf("  %d", ir);
            x = x0 + norm(x0) * randn(size(x0));
            if (size(x0) <= 10^3)
                [f, g, H] = objective(x);  % Time consuming to evaluate H
            else
                [f, g] = objective(x);
            end
            if ~isempty(nonlcon)
                if (size(x0) * p.numnlcon <= 10^6)
                   [cineq, ceq, gcineq, gceq] = nonlcon(x);  % Time consuming to evaluate gcineq and gceq
                else
                   [cineq, ceq] = nonlcon(x);
                end
            end
        end
        teval = toc(tstart);
        fprintf("  %g", 100*teval);

        decup(pname);
    catch
        isbad(ip) = true;
    end

    fprintf("\n");
end
badlist = plist(isbad);

fprintf('\n');
toc(t0);
fprintf('\n');
