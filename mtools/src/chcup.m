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
    nr = 100;
end

badlist = {};
np = length(plist);
tic;

for ip = minip : np
    pname = plist{ip};
    fprintf("%d. %s\n", ip, pname);

    try
         p = macup(pname);
         for ir = 1 : nr
             x0 = p.x0;
             x = x0 + norm(x0) * randn(size(x0));
             p.objective(x);
             if ~isempty(p.nonlcon)
                 p.nonlcon(x);
             end
         end
         decup(pname);
     catch
         badlist = [badlist, {pname}];
     end

end

fprintf('\n');
toc;
fprintf('\n');
