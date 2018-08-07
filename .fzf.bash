# Setup fzf
# ---------
if [[ ! "$PATH" == */home/barries/.fzf/bin* ]]; then
  export PATH="$PATH:/home/barries/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/barries/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/barries/.fzf/shell/key-bindings.bash"

