function setup()
%SETUP sets up matlab tools for CUTEst.

% Try saving path. Do this before calling `getcup`.
path_saved = add_save_path(fullfile(cd(), 'src'));

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
    if getcup()
        fprintf(fid, '1');
        if ~path_saved
            warning('SETUP:PathNotSaved', 'Failed to save path.');
            fprintf('\nTo use the package in any other MATLAB session, run the following command first:\n\n');
            fprintf('addpath(''%s'')\n\n', fullfile(cd(), 'src'));
        end
    else
        fprintf(fid, '0');
    end
end

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [path_saved, edit_startup_failed] = add_save_path(path_string)
%ADD_SAVE_PATH adds the path indicated by PATH_STRING to the matlab path and then tries saving path.

path_string = fullfile(path_string);
addpath(path_string);
path_saved = false;
edit_startup_failed = false;

% Try saving path.
orig_warning_state = warning;
warning('off', 'MATLAB:SavePath:PathNotSaved'); % Maybe we do not have the permission to save path.
if savepath == 0 || (numel(userpath) > 0 && savepath(fullfile(userpath, 'pathdef.m')) == 0)
    % SAVEPATH saves the current MATLABPATH in the path-defining file,
    % which is by default located at:
    % fullfile(matlabroot, 'toolbox', 'local', 'pathdef.m')
    % It returns 0 if the file was saved successfully; 1 otherwise.
    % If savepath fails (probably because we do not have the permission to
    % write the above pathdefi.m file), then we try saving the path to the
    % user-specific pathdef.m file, which is located in userpath.
    % On linux, userpath = '$HOME/Documents/MATLAB'. However, if $HOME/Documents
    % does not exist, then userpath = []. In this case, we will not save path
    % to the user-specific pathdef.m file. Otherwise, we will only get a pathdef.m
    % in the current directory, which will not be executed when MATLAB starts
    % from other directories.

    path_saved = true;
end
warning(orig_warning_state); % Restore the behavior of displaying warnings

% If path not saved, try editing the startup.m of this user
user_startup = fullfile(userpath,'startup.m');
add_path_string = sprintf('addpath(''%s'');', fullfile(path_string));
full_add_path_string = sprintf('%s\t%s Added by MatCUTEst', add_path_string, '%');
% First, check whether full_add_path_string already exists in user_startup or not
if exist(user_startup, 'file')
    startup_text_cells = regexp(fileread(user_startup), '\n', 'split');
    if any(strcmp(startup_text_cells, full_add_path_string))
        path_saved = true;
    end
end
if ~path_saved && numel(userpath) > 0
    % On linux, userpath = '$HOME/Documents/MATLAB'. However, if $HOME/Documents
    % does not exist, then userpath = [], and user_startup = 'startup.m'.
    % In this case, we will not use user_startup. Otherwise, we will only get
    % a startup.m in the current directory, which will not be executed when
    % MATLAB starts from other directories.

    % We first check whether the last line of the user startup script is an
    % empty line (or the file is empty or even does not exist at all).
    % If yes, we do not need to put a line break before the path adding string.
    if exist(user_startup, 'file')
        startup_text_cells = regexp(fileread(user_startup), '\n', 'split');
        last_line_empty = isempty(startup_text_cells) || (isempty(startup_text_cells{end}) && isempty(startup_text_cells{max(1, end-1)}));
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
        if exist(user_startup, 'file')
            startup_text_cells = regexp(fileread(user_startup), '\n', 'split');
            if any(strcmp(startup_text_cells, full_add_path_string))
                path_saved = true;
            end
        end
    end
    if ~path_saved
        edit_startup_failed = true;
    end
end
