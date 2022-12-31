function blacklist = chcup(plist, minip, nr)
%CHCUP (CHeck CUtest Problems) checks whether the CUTEst problems in PLIST work. It tries making the
% problem, and the evaluates the objective and constraint (if any) functions at NR points. MINIP
% is the minimal index of the number to check. If MATLAB crashes (which did happen) when checking
% problem IP, we then add PLIST{IP} to the BLACKLIST in SECUP, and then run the function again
% with MINIP = IP, until all problems are checked.

if ischar(plist) || isstring(plist)
    plist = {plist};
end

if nargin <= 1
    minip = 1;
end

if nargin <= 2
    nr = 50;
end

blacklist = {};
np = length(plist);
for ip = minip : np
    pname = plist{ip};
    fprintf("%d. %s\n", ip, pname);

   try
        p = macup(pname);
        for ir = 1 : nr
            x0 = p.x0;
            r = randn(size(x0));
            r = r / norm(r);
            x = x0 + 0.1 * norm(x0)*r;
            y = p.objective(x);
            if ~isempty(p.nonlcon)
                [cineq, ceq] = p.nonlcon(x);
            end
        end
    catch
        blacklist = [blacklist, {pname}];
    end
end
