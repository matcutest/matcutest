# MatCUTEst

[![license](https://img.shields.io/badge/license-LGPLv3+-blue)](https://github.com/equipez/matcutest/blob/main/LICENCE.txt)
[![CI](https://github.com/equipez/matcutest/actions/workflows/ci.yml/badge.svg)](https://github.com/equipez/matcutest/actions/workflows/ci.yml)

## What is this?

MatCUTEst is a package facilitating the usage of [CUTEst](https://github.com/ralna/CUTEst) in MATLAB on Linux.

N.B.: Using CUTEst in MATLAB on MacOS is not supported anymore as of 2022. See the discussions in [CUTEst issue 28](https://github.com/ralna/CUTEst/issues/28).


## How to use?

If you are using MATLAB R2020a or above on Ubuntu 20.04 or above, you should **first try the
[**compiled version of MatCUTEst**](https://github.com/equipez/matcutest_compiled). Do the following
**only if** that version does not work.

First of all, clone this repository to the place where you want MatCUTEst to be installed.
You should then get a directory containing this README file.
We will refer to this directory as "**[the current directory]**" in the sequel.

1. Run the following in the terminal under **[the current directory]**:

    ```bash
    bash ./INSTALL
    ```

   It will install CUTEst and then mexify all the problems, **which may take a few hours**.

2. After 1, any CUTEst problem can be obtained in MATLAB by

   ```matlab
   macup(PROBLEM_NAME)
   ```

   where you have to replace PROBLEM_NAME by a string that is the name
   of the problem. For example, try

   ```matlab
   macup('AKIVA')
   ```

   This should give you a structure containing the full information of
   problem AKIVA, including its objective function, constraints (if any),
   starting point, etc. Try `help matcutest` in MATLAB or see [`mtools/README.txt`](mtools/README.txt)
   for more information.


## Use MatCUTEst in GitHub Actions

If you want to use MatCUTEst in [GitHub Actions](https://docs.github.com/en/actions), see
the [demo](https://github.com/equipez/matcutest_compiled/blob/main/.github/workflows/demo.yml).
MatCUTEst has been used intensively in the testing and development of [PRIMA](http://www.libprima.net),
where you can find more [realistic examples](https://github.com/libprima/prima/blob/main/.github/workflows/verify_large.yml)
of using MatCUTEst in GitHub Actions.


## Thread safety

MatCUTEst is [thread-safe](https://en.wikipedia.org/wiki/Thread_safety). It can be used within
a [`parfor` loop](https://www.mathworks.com/help/parallel-computing/parfor.html). Here is an example.

```matlab
problist = {'AKIVA', 'BOX2', 'ZECEVIC2', 'ZY2'};
parfor ip = 1 : length(problist)
    pname = problist{ip};
    fprintf('\n%d. Try %s:\n', ip, pname);
    p = macup(pname);  % make a CUTEst problem
    p.objective(p.x0)
    decup(p);  % destroy the CUTEst problem
end
```


## Remarks

- MatCUTEst has been playing a vital role in the testing and development of [PRIMA](http://www.libprima.net).
- If you would like to use CUTEst in Python, check [PyCUTEst](https://github.com/jfowkes/pycutest).
