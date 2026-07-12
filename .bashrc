# ╔══════╗
#  BASHRC
# ╚══════╝

# Enable the subsequent settings only in interactive sessions.
# This prevents the custom commands in this .bashrc from running if something like a Python script loads the .bashrc.
# Not a human using a terminal? --> Don't need the extra features.
case "$-" in
  *i*) ;;
    *) return;;
esac

# Check if system-wide/global /etc/bashrc config exists. If it does, source it.
# Effectively this allows for applying system defaults before this file's custom overrides.
[[ -r /etc/bashrc ]] && . /etc/bashrc

# ╔════════════════════════╗
#  TERMINAL STARTUP GRAPHIC
# ╚════════════════════════╝

# Option to add a system-info display upon terminal startup.
# See https://github.com/dylanaraps/neofetch

#neofetch --config ~/.neofetch

# ╔══════════════╗
#  PATH ADDITIONS
# ╚══════════════╝

# A simple `export PATH="/path/to/directory:$PATH"` will re-add the directory to your PATH every time the command source ~/.bashrc is run.
# We do not want the PATH arbitrarily growing each time the .bashrc is sourced.

# Prepend $PATH with a directory ($1) only if the new path is not already in $PATH
# If $PATH is empty, don't include the ":" --> Bash parameter expansion syntax ${variable:+replacement}
# If variable is set and not empty, use replacement. Otherwise, use nothing.
__path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="$1${PATH:+:$PATH}" ;;
    esac
}

# Append $PATH with a directory ($1) only if the new directory is not already in $PATH
__path_append() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) export PATH="${PATH:+$PATH:}$1" ;;
    esac
}

# Example usage - creating a symlink titled "python" pointing to your preferred Python binary (executable),
# and prepending the directory it's under (/python_symlink/) to your $PATH so it becomes the Python interpreter
# invoked when you use the command "python" (i.e. A custom Python shim)
# (Call these within the .bashrc itself)

#__path_prepend "/home/<username>/python_symlink"

# ╔═══════╗
#  ALIASES
# ╚═══════╝

# My preferred `ls` functionality
alias ll='ls -l --almost-all --file-type'

# Nice to have, often set by default in many Linux distributions
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# ╔═════════════╗
#  PIP/PIPENV/UV
# ╚═════════════╝

# Force pip to only run inside a virtual environment
export PIP_REQUIRE_VIRTUALENV=true

# Make Pipenv create virtual environments inside the project folder (.venv/) instead of using some global location
export PIPENV_VENV_IN_PROJECT=1

# ╔═════════╗
#  FUNCTIONS
# ╚═════════╝

# Recursive search for string inside files under current directory
# Matches whole word only (e.g. "cat" won't match "concatenate")
# Boundaries are all characters besides letters, digits, and underscores (e.g. "cat" in "cat-dog" will match, as would "-dog")
fstr() {
    if [[ -z ${1:-} ]]; then  # Replacement of unset $1 with an empty string is safer than relying on conditional check of raw empty variable
        printf '%s\n' "Usage: fstr SEARCH_STRING" >&2  # ">&2" prevents usage string from being included if results are >'d to a .txt file
        return 2
    fi

    grep --dereference-recursive --line-number --word-regexp "." --regexp="$1"
}

# Print $PATH with one line per component
path() {
    printf '%s\n' "${PATH//:/$'\n'}"
}

# Change directory to the root of the current Git repository, if possible
# Fails loudly if not currently in a Git repository
groot() {
    local root
    root=$(git rev-parse --show-toplevel)
    cd "$root"
}

# Show disk usage for all items in the current directory from largest to smallest.
# Run in a subshell so toggling `dotglob` and `nullglob` remains local.
sizes() (
    # Make `*` include filenames beginning with a dot without including the "special directory entires" `.` and `..`.
    shopt -s dotglob

    # If `*` matches no files, expand it to zero arguments instead of passing the literal string `*`
    shopt -s nullglob

    # Build array out of what `*` returns
    local items=( * )

    # If the current directory contains no items, return successfully without invoking `du`.
    ((${#items[@]})) || return 0

    du --summarize --human-readable -- "${items[@]}" |
        sort --human-numeric-sort --reverse
)

# Print a variety of system information
# Descriptions derived from man pages
systembarf() {
    local cyan=$'\033[36m'
    local reset=$'\033[0m'

    # Print the user name associated with the current effective user ID
    printf '\n%s== whoami ==%s\n\n' "$cyan" "$reset"
    whoami

    # Print user and group information for the current user
    printf '\n%s== id ==%s\n\n' "$cyan" "$reset"
    id

    # System hostname and machine/OS metadata
    printf '\n%s== hostnamectl ==%s\n\n' "$cyan" "$reset"
    hostnamectl

    # Linux distribution details
    printf '\n%s== /etc/os-release ==%s\n\n' "$cyan" "$reset"
    cat /etc/os-release

    # One line display of the following information:
    # The current time, how long the system has been running, how many users are currently
    # logged on, and the system load averages for the past  1, 5, and 15 minutes
    printf '\n%s== uptime ==%s\n\n' "$cyan" "$reset"
    uptime

    # A variety of time-related information
    printf '\n%s== timedatectl ==%s\n\n' "$cyan" "$reset"
    timedatectl

    # Print the following system information:
    # kernel name, node name, kernel release, kernel version, machine hardware name, processor type (if known)
    # hardware platform (if known), operating system, version information
    printf '\n%s== uname -all ==%s\n\n' "$cyan" "$reset"
    uname --all

    # CPU architecture and core/thread count information
    printf '\n%s== lscpu ==%s\n\n' "$cyan" "$reset"
    lscpu

    # Memory and swap usage
    printf '\n%s== free --human ==%s\n\n' "$cyan" "$reset"
    free --human

    # Block device, partition, and mount relationship information
    printf '\n%s== lsblk ==%s\n\n' "$cyan" "$reset"
    lsblk

    # Disk space available
    printf '\n%s== df --human-readable ==%s\n\n' "$cyan" "$reset"
    df --human-readable

    # PCI bus and connected device information
    printf '\n%s== lspci ==%s\n\n' "$cyan" "$reset"
    lspci

    # USB bus and connected device information
    printf '\n%s== lsusb ==%s\n\n' "$cyan" "$reset"
    lsusb
}

# ╔═══╗
#  PS1
# ╚═══╝

# Colors
RED="\[\033[31m\]"
GREEN="\[\033[32m\]"
GRAY="\[\033[38;2;150;150;150m\]"  # Subtle gray for command timer and Python version display
GIT_ORANGE="\[\033[38;2;241;78;50m\]"  # f14e32  Official Git orange
RESET="\[\033[0m\]"

# Helper to determine whether the user is inside a git repository.
__inside_git_repo() { git rev-parse --is-inside-work-tree >/dev/null 2>&1; }

# Take an exit code and print a colored success/failure icon based on the value. Green smiley = Succeeded. Red smiley = Failed.
command_status_icon() { local exit_code=$1; [[ $exit_code -eq 0 ]] && printf '%s' "${GREEN}${RESET}" || printf '%s' "${RED}${RESET}"; }

# Print a colored icon based on whether a Python virtual environment is active. Green shield = Active. Red shield = Vulnerable.
venv_status_icon() { [[ -n "$VIRTUAL_ENV" ]] && printf '%s' "${GREEN}󰒙${RESET}" || printf '%s' "${RED}󰫝${RESET}"; }

# Print the active virtual environment name, if one is active.
venv_name() { [[ -n "$VIRTUAL_ENV" ]] && printf '%s' "${RESET}(${VIRTUAL_ENV##*/})${RESET} "; }

# Print a green directory with the Git logo when inside a work tree, otherwise red.
git_status_icon() { __inside_git_repo && printf '%s' "${GREEN}${RESET}" || printf '%s' "${RED}${RESET}"; }

# Print the branch, tag, or commit currently identified by Git HEAD.
# Orange color is added separately to assist with width determination.
git_status_string() {
    local ref git_ref_icon

    # Early return if not inside a git repository
    __inside_git_repo || return

    # HEAD is a symbolic reference to a branch (and the branch points to a commit)
    if ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
        git_ref_icon="󰘬"

    # HEAD is detached and points to a tagged commit
    elif ref=$(git describe --tags --exact-match HEAD 2>/dev/null); then
        git_ref_icon=""

    # HEAD is detached and points to an untagged commit
    elif ref=$(git rev-parse --short HEAD 2>/dev/null); then
        git_ref_icon=""

    # Unknown git state
    else
        git_ref_icon=""
        ref="unknown"
    fi

    printf '%s %s' "$git_ref_icon" "$ref"
}

# If a file titled "python" exists on PATH, print a green Python logo icon and label it with the Python version if possible.
# Print red Python logo for all other cases.
# This is dependent on the "python" file in question either being a Python binary/executable, or a symlink pointing to one.
python_status_icon() {
    local python_version

    # Attempt to determine Python version by calling "python" and early exit if it fails
    python_version=$(python -V 2>/dev/null) || {
        printf '%s' "${RED}󰌠${RESET}"
        return
    }

    # If the above succeeds, strip the "Python" from "Python #.#.#"
    python_version=${python_version#Python }

    # Print green Python logo with version returned by the associated Python interpreter
    printf '%s %s%s%s' "${GREEN}󰌠${RESET}" "${GRAY}" "$python_version" "${RESET}"
}

# Take a time duration in seconds and convert it to a nice string. e.g. 5 -> 5s, 266453 -> 3d 2h 53s
__timer_formatter() {
    local duration_seconds=$1  # Integer (s) gets passed in

    local days hours minutes seconds
    local formatted_duration=()

    # Handle sub-second resolution gracefully.
    # This is mostly to make the user-experience more predictable than using finer granularity and
    # having repeated short commands yield different times every run.
    # print "<1s" if duration is < 1s
    if (( duration_seconds < 1 )); then
        printf '%s' '<1s'
        return
    fi

    days=$(( duration_seconds / 86400 ))
    hours=$(( duration_seconds / 3600 % 24 ))
    minutes=$(( duration_seconds / 60 % 60 ))
    seconds=$(( duration_seconds % 60 ))

    (( days )) && formatted_duration+=("${days}d")
    (( hours )) && formatted_duration+=("${hours}h")
    (( minutes )) && formatted_duration+=("${minutes}m")
    (( seconds )) && formatted_duration+=("${seconds}s")

    printf '%s' "${formatted_duration[*]}"
}

# Determine padding needed to right-align the command-timer string on the first prompt line.
__timer_padding() {
    local prompt_string=$1  # The first line of the PS1 prompt itself
    local timer_string=$2  # The literal timer string

    local prompt_width=${#prompt_string}
    local timer_width=${#timer_string}
    local terminal_width=${COLUMNS:-80}  # Fallback to 80 default
    local padding

    # Terminal width - (prompt width + timer string width) = padding needed
    padding=$((terminal_width - prompt_width - timer_width))

    # If (prompt + timer) is equal to or greater than width of terminal, force the padding to be one space regardless
    (( padding < 1 )) && padding=1

    printf '%*s' "$padding" ''
}

# Assemble the actual PS1 prompt from the various components
__build_prompt() {
    local exit_code=$1  # Exit code to pass to command_status_icon function - intended to be the user's previous command
    local timer_string=$2  # Formatted string of some time duration - intended to be the duration of the user's previous command

    local cwd
    local datetime
    local git_string
    local padding
    local prompt_line_1
    local prompt_line_2

    # Mimic PS1 escape sequence behavior manually (e.g. \w=cwd) in order to count the resultant string width(s)
    # The built-in escape sequences only render upon prompt display. If the built-in escape sequences are used, padding for
    # the timer string would not be possible to calculate.
    datetime=$(date "+%m/%d/%Y %H:%M")
    cwd=$PWD
    case $cwd in
        "$HOME") cwd='~' ;;
        "$HOME"/*) cwd="~/${cwd#"$HOME"/}" ;;
    esac

    # Cache this for multiple invocations
    git_string=$(git_status_string)

    # Pass the various strings into the __timer_padding function to determine padding
    padding=$(__timer_padding "${USER} ${datetime} ${cwd} ${git_string}" "$timer_string")

    # PS1 line 1 - user, date, time, cwd, git ref (timer string added below)
    prompt_line_1="${USER} ${datetime} ${cwd} ${GIT_ORANGE}${git_string}${RESET}"

    # PS1 line 2 - venv name, previous command status icon, venv status icon, git status icon, and python status icon and version
    prompt_line_2="$(venv_name)$(command_status_icon "$exit_code") $(venv_status_icon) $(git_status_icon) $(python_status_icon) "

   # Stack the PS1 lines 1 & 2 together, and add the timer string to line 1 with appropriate padding
   # Start with a newline to space user-prompt away from prior output
    PS1=$'\n'"${prompt_line_1}${padding}${GRAY}${timer_string}${RESET}"$'\n'"${prompt_line_2}"
}

# ╔═════════════╗
#  TIMER BACKEND
# ╚═════════════╝

# Helper function to get current Unix timestamp (s)
__current_unix_timestamp() {
    date +%s
}

# THIS FUNCTION IS EXECUTED BY "trap '__get_start_timestamp' DEBUG"
# Capture a start timestamp for commands.
# CLAIM: If global variable __ready_for_user_command = 1, the command that fired the DEBUG trap is a user command, and we want to time it.
__get_start_timestamp() {
    # Capture exit status of the previous command
    local exit_status=$?

    # If global variable __ready_for_user_command = 1, capture a "start" timestamp
    # If global variable __ready_for_user_command = 0, do nothing
    if (( __ready_for_user_command )); then
        __ready_for_user_command=0  # Reset to 0
        user_command_start_timestamp=$(__current_unix_timestamp)
    fi

    # Return previous command's exit status as __get_start_timestamp()'s exit status to preserve the user's ability to rely on the exist status variable ($?).
    # The DEBUG trap will often, and every command inside __get_start_timestamp() will update the value of "$?".
    # e.g. The simplest demonstration of this is if a user calls "echo $?", the "echo" in "echo $?" will trip the DEBUG trap, and thus when "$?" actually prints, it may show
    # an erroneous exit status relative to the user's needs/expectations.
    return "$exit_status"
}

# Capture a stop timestamp and calculate the difference with global variable "user_command_start_timestamp" if possible
# Sets global variable "command_duration_string"
__compute_duration() {
    # If global variable "user_command_start_timestamp" is NOT empty, take a current timestamp and calculate the difference.
    # Feed the result into __timer_formatter().
    # Otherwise, (.bashrc freshly source'd, etc.), set the duration value to "N/A"
    if [[ -n $user_command_start_timestamp ]]; then
        command_duration_string=$(__timer_formatter "$(($(__current_unix_timestamp) - user_command_start_timestamp))")

        # Reset the start timestamp to empty
        user_command_start_timestamp=

    # If global variable "user_command_start_timestamp" IS empty, set the duration value to "N/A"
    else
        command_duration_string='N/A'
    fi
}

# ╔══════════╗
#  ENTRYPOINT
# ╚══════════╝

# Define the PROMPT_COMMAND hook
__prompt_command() {
    # Capture exit status of the previous command
    local exit_code=$?

    # Set global variable "command_duration_string"
    __compute_duration

    # Build and render the PS1 user-prompt
    __build_prompt "$exit_code" "$command_duration_string"

    # After the user-prompt renders, bash is waiting for the user to type a command
    __ready_for_user_command=1

    return "$exit_code"
}

# Instantiate a "start" timestamp variable
# When .bashrc is sourced, start with no recorded command start time
user_command_start_timestamp=

# This represents whether bash is waiting for the user to type a command, and is used by the timer feature.
# Initialize this to "0" when .bashrc is sourced.
# This is set to "1" immediately after the user-prompt renders.
# This gets set back to "zero" when the user executes a command.
__ready_for_user_command=0

# Turn off parameter expansion, command substitution, arithmetic expansion, and quote removal after being expanded.
# We are building the user-prompt manually and take care of this ourselves.
shopt -u promptvars

# Register the PROMPT_COMMAND hook
# WARNING: This completely overrides anything that previously adjusted PROMPT_COMMAND
PROMPT_COMMAND=__prompt_command

# Register DEBUG trap to call __get_start_timestamp()
# This will execute __get_start_timestamp() before every:
# simple command
# for command
# case command
# select command
# (( arithmetic command
# [[ conditional command
# arithmetic for command
# and before the first command executes in a shell function.
# Namely, this includes any command a user may run - the command we want to time
# https://www.gnu.org/software/bash/manual/bash.html#index-trap
trap '__get_start_timestamp' DEBUG