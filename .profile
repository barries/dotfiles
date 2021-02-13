# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

PATH="$PATH:bin:../Tools/bin" # For source-tree (i.e. branch-specific) bins

#Removed for X2Go compatability (prevents "inappropriate ioctl for device"): stty -ixon # Disable ^S/^Q

export EDITOR=nvim

export GTEST_COLOR=1
export "GDB_FLAGS=-iex 'set confirm off' -iex 'set pagination off' -iex 'set follow-fork-mode parent' -iex 'set detach-on-fork on' -ex 'catch throw' -ex 'catch catch' -ex run"

