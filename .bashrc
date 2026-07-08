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
# If variable is set and not empty, use  replacement. Otherwise, use nothing.
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
# and prepending the dirictory it's under (/python_symlink/) to your $PATH so it becomes the Python interpreter
# invoked when you use the command "python" (i.e. A custon Python shim)

#__path_prepend "/home/<username>/python_symlink"

# ╔═══════╗
#  ALIASES
# ╚═══════╝

# My preferred "ls" functionality
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

# Show disk usage for all items in the current directory from largest to smallest
# Does not include files starting with two dots (e.g. ..foo)
sizes() {
    du --summarize --human-readable -- * .[^.]* 2>/dev/null | sort --human-numeric-sort --reverse
}

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
GRAY="\[\033[38;2;150;150;150m\]"
GIT_ORANGE="\[\033[38;2;241;78;50m\]" #f14e32
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

# Print the current Git ref as plain text for prompt display.
# Orange color is added separately to assist with width determination.
git_status_string() {
    local ref git_ref_icon

    # Early return if not inside a git repository
    __inside_git_repo || return

    # Checked out reference is a branch
    if ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
        git_ref_icon="󰘬"

    # Checked out reference is a tag
    elif ref=$(git describe --tags --exact-match HEAD 2>/dev/null); then
        git_ref_icon=""

    # Checked out reference is a detached commit
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