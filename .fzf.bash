# Setup fzf
# ---------
if [[ ! "$PATH" == */home/barrie/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/barrie/.fzf/bin"
fi

eval "$(fzf --bash)"
