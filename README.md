# MatCUTEst

MatCUTEst is a package for facilitating the usage of [CUTEst](https://github.com/ralna/CUTEst) in MATLAB on Linux.

N.B.: Using CUTEst in MATLAB on MacOS is not supported anymore as of 2022. See the discussions in [CUTEst issue 28](https://github.com/ralna/CUTEst/issues/28).

[Zaikun Zhang](https://www.zhangzk.net), Dec 29, 2022, Hong Kong


## How to use?

First of all, clone this repository to the place where you want MatCUTEst to be installed.
You should then get a directory containing this README file.
We will refer to this directory as "**[the current directory]**" in the sequel.

1. Run the following in the terminal under **[the current directory]**:
    ```
    bash ./INSTALL
    ```

   It will compile all the problems, **which may take a few hours**.

2. Append the following line to the [`.bashrc` file under your home directory](https://www.bing.com/search?q=what+is+.bashrc):

    ```
    source [the current directory]/matcutestrc
    ```

   N.B.: Remember to replace "**[the current directory]**" with the full path to the directory containing this README!


3. After 2, any CUTEst problem can be obtained in MATLAB by

   ```
   macup(PROBLEM_NAME)
   ```

   where you have to replace PROBLEM_NAME by a string that is the name
   of the problem. For example, try

   ```
   macup('AKIVA')
   ```

   This should give you a structure containing the full information of
   problem AKIVA, including its objective function, constraints (if any),
   starting point, etc. See [`mtools/README.txt`](mtools/README.txt) for more information.
