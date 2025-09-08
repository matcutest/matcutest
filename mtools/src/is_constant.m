function ic = is_constant(fun, x0, ntest)
% IS_CONSTANT tests whether a function is a constant. We evaluate the function at ntest + 1 random
% points. If the function values are all the same and the gradients are all zero, then we consider
% the function a constant.

% Set rng state for reproducibility
orig_rng_state = rng();
rng(0);

try
    [f0, g0] = fun(x0);
    ic = all(g0 == 0);
catch
    ic = false;  % In case fun fails, it is not a constant
end

if ic
    for itest = 1:ntest
        x = x0 + 10^(2*rand) * randn(size(x0));
        try
            [f, g] = fun(x);
            ic = (f == f0 && all(g == 0));
        catch
            ic = false;
        end
        if ~ic
            break;
        end
    end
end

% Restore original rng state
rng(orig_rng_state);

return
