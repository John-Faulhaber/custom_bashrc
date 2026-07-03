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