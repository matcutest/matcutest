function nums = numcup(prob)
%NUMCUP computes several numbers with names starting with 'num' for a CUTEst problem.

    cutest_inf = 1e20;
    bl = prob.bl;
    bu = prob.bu;
    cl = prob.cl;
    cu = prob.cu;
    linear = prob.linear;
    equatn = prob.equatn;

    bl(bl <= -cutest_inf) = -inf;
    bu(bu >= cutest_inf) = inf;
    cl(cl <= -cutest_inf) = -inf;
    cu(cu >= cutest_inf) = inf;

    % Compute the numbers
    numlb = nnz(bl > -inf);
    numub = nnz(bu < inf);
    numb = nnz(bl > -inf) + nnz(bu < inf);
    numfixedx = nnz(abs(bl - bu) < eps);

    numlc = nnz(cl > -inf);
    numlu = nnz(cu < inf);

    if isempty(linear)
        numcon = 0;
        numlcon = 0;
        numnlcon = 0;
        numeq = 0;
        numineq = 0;
        numleq = 0;
        numlineq = 0;
        numnleq = 0;
        numnlineq = 0;
    else
        leq = linear & equatn;
        nleq = ~linear & equatn;

        numeq = nnz(equatn);
        numleq = nnz(leq);
        numnleq = nnz(nleq);

        % Note that `numeq = nnz(cl == cu)`. Thus, in the definition of
        % `numcon`, we need to minus `numeq` once since it is counted twice.
        numcon = (2*length(linear) - numeq) - nnz(cl <= -inf) - nnz(cu >= inf);
        numlcon = (2*nnz(linear) - numleq) - nnz(linear & cl <= -inf) - nnz(linear & cu >= inf);
        numnlcon = (2*nnz(~linear) - numnleq) - nnz(~linear & cl <= -inf) - nnz(~linear & cu >= inf);
        numineq = 2*(length(linear) - numeq) - nnz(cl <= -inf) - nnz(cu >= inf);
        numlineq = 2*(nnz(linear) - numleq) - nnz(linear & cl <= -inf) - nnz(linear & cu >= inf);
        numnlineq = 2*(nnz(~linear) - numnleq) - nnz(~linear & cl <= -inf) - nnz(~linear & cu >= inf);
    end

    % Assert the consistency of the computed numbers
    assert(numlb >= 0);
    assert(numub >= 0);
    assert(numb >= 0);
    assert(numfixedx >= 0);
    assert(numcon >= 0);
    assert(numlcon >= 0);
    assert(numnlcon >= 0);
    assert(numeq >= 0);
    assert(numineq >= 0);
    assert(numleq >= 0);
    assert(numlineq >= 0);
    assert(numnleq >= 0);
    assert(numnlineq >= 0);

    assert(numb == numlb + numub);
    assert(numcon == numlcon + numnlcon);
    assert(numcon == numeq + numineq);
    assert(numlcon == numleq + numlineq);
    assert(numnlcon == numnleq + numnlineq);
    assert(numeq == numleq + numnleq);
    assert(numineq == numlineq + numnlineq);
    assert(numlc <= numcon && numlu <= numcon && numlc + numlu >= numcon);

    % Return the numbers in a structure
    nums.numlb = numlb;
    nums.numub = numub;
    nums.numb = numb;
    nums.numfixedx = numfixedx;
    nums.numcon = numcon;
    nums.numlcon = numlcon;
    nums.numnlcon = numnlcon;
    nums.numeq = numeq;
    nums.numineq = numineq;
    nums.numleq = numleq;
    nums.numlineq = numlineq;
    nums.numnleq = numnleq;
    nums.numnlineq = numnlineq;
end