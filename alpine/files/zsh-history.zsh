
# knot: keep shell history. zsh saves none unless told to, so out of the box
# nothing survives a session. Set before ~/.zshrc runs, so users can override.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
# Write each command as it's entered, so history survives a shell that is killed
setopt APPEND_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS
