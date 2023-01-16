function setup(action)
%SETUP sets up matlab tools for CUTEst.

% Try saving path. Do this before calling `getcup`.
mdir = fileparts(mfilename('fullpath')); % The directory containing this script.
src_path = fullfile(mdir, 'src');
path_saved = add_save_path(src_path);

if nargin == 1 && (isa(action, 'char') || isa(action, 'string')) && strcmp(action, 'path')
    fprintf('\nPath added.\n\n')
    return
end

% Mexify the CUTEst problems, if needed.
gotcup = false;

if exist('GOTCUP', 'file')
    fid = fopen('GOTCUP', 'r');
    if fid == -1
        error('Failed to open ''GOTCUP''.');
    end
    s = textscan(fid, '%f');
    gotcup = (~isempty(s) && ~isempty(s{1}) && s{1} ~= 0);
end

if gotcup
    fprintf('\nsetup has been done before. Remove the ''GOTCUP'' file in this directory if you want to redo it.\n\n');
else
    fid = fopen('GOTCUP', 'w');
    if fid == -1
        error('Failed to open ''GOTCUP''.');
    end
    if getcup()  % getcup() mexifies the problems
        fprintf(fid, '1');
    else
        fprintf(fid, '0');
    end
end

if ~path_saved
    warning('MatCUTEst:PathNotSaved', 'Failed to save path.');
    add_path_string = sprintf('addpath(''%s'');', src_path);
    fprintf('\n***** To use the package in other MATLAB sessions, do ONE of the following. *****\n\n');
    fprintf('- Append the following line to your startup script\n');
    fprintf('  (see https://www.mathworks.com/help/matlab/ref/startup.html for information):\n\n');
    fprintf('    %s\n\n', add_path_string);
    fprintf('- OR come to the current directory and run ''setup path'' when you need the package.\n\n');
end

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [path_saved, edit_startup_failed] = add_save_path(path_string)
%ADD_SAVE_PATH adds the path indicated by PATH_STRING to the matlab path and then tries saving path.

addpath(path_string);
edit_startup_failed = false;

% Try saving the path in the system path-defining file at sys_pathdef. If the user does not have
% writing permission for this file, then the path will not saved.
% N.B. Do not save the path to the pathdef.m file under userpath. This file is not loaded by default
% at startup. See
% https://www.mathworks.com/matlabcentral/answers/269482-is-userdata-pathdef-m-for-local-path-additions-supported-on-linux
orig_warning_state = warning;
warning('off', 'MATLAB:SavePath:PathNotSaved'); % Maybe we do not have the permission to save path
sys_pathdef = fullfile(matlabroot(), 'toolbox', 'local', 'pathdef.m');
path_saved = (savepath(sys_pathdef) == 0);
warning(orig_warning_state); % Restore the behavior of displaying warnings

% If path not saved, try editing the startup.m of this user. Do this only if userpath is nonempty.
% Otherwise, we will only get a startup.m in the current directory, which will not be executed
% when MATLAB starts from other directories. On Linux, the default value of userpath is
% ~/Documents/MATLAB, but it will be '' if this directory does not exist. We refrain from creating
% this directory in that case.
if ~path_saved && numel(userpath) > 0
    user_startup = fullfile(userpath, 'startup.m');
    add_path_string = sprintf('addpath(''%s'');', path_string);
    full_add_path_string = sprintf('%s\t%s Added by MatCUTEst', add_path_string, '%');

    % First, check whether full_add_path_string already exists in user_startup or not
    if exist(user_startup, 'file')
        startup_text_cells = regexp(fileread(user_startup), '\n', 'split');
        path_saved = any(strcmp(startup_text_cells, full_add_path_string));
    end

    if ~path_saved
        % We first check whether the last line of the user startup script is an
        % empty line (or the file is empty or even does not exist at all).
        % If yes, we do not need to put a line break before the path adding string.
        if exist(user_startup, 'file')
            startup_text_cells = regexp(fileread(user_startup), '\n', 'split');
            last_line_empty = isempty(startup_text_cells) || (isempty(startup_text_cells{end}) && ...
                isempty(startup_text_cells{max(1, end-1)}));
        else
            last_line_empty = true;
        end
        file_id = fopen(user_startup, 'a');
        if file_id ~= -1 % If FOPEN cannot open the file, it returns -1
            if ~last_line_empty  % The last line of user_startup is not empty
                fprintf(file_id, '\n');  % Add a new empty line
            end
            fprintf(file_id, '%s', full_add_path_string);
            fclose(file_id);
            % Check that full_add_path_string is indeed added to user_startup.
            if exist(user_startup, 'file')
                startup_text_cells = regexp(fileread(user_startup), '\n', 'split');
                path_saved = any(strcmp(startup_text_cells, full_add_path_string));
            end
        end
    end
    edit_startup_failed = (~path_saved);
end
