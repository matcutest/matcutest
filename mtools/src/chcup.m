function badlist = chcup(plist, minip, nr)
%CHCUP (CHeck CUtest Problems) checks whether the CUTEst problems in PLIST work. It tries making the
% problem, and then evaluates the objective and constraint (if any) functions at NR points. MINIP
% is the minimal index of the number to check. If MATLAB crashes (which did happen) when checking
% problem IP, we then add PLIST{IP} to the BLACKLIST in SECUP, and then run CHCUP again with
% MINIP = IP, until all problems are checked.

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
    nr = 30;
end

np = length(plist);
isbad = false(np, 1);

t0 = tic;

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
            objective(x);
            if ~isempty(nonlcon)
                nonlcon(x);
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
