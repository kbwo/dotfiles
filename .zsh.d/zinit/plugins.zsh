bindkey '^j' autosuggest-accept
zinit wait lucid light-mode for \
    'agkozak/zsh-z' \
    'joshskidmore/zsh-fzf-history-search' \
    'zsh-users/zsh-syntax-highlighting' \
    'zsh-users/zsh-completions' \
    'migutw42/zsh-fzf-ghq' \
    'zsh-users/zsh-autosuggestions'
autoload -Uz compinit && compinit
