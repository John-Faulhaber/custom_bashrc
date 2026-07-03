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