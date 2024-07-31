zinit load agkozak/zsh-z
zinit light zsh-users/zsh-autosuggestions
bindkey '^j' autosuggest-accept
zinit wait lucid light-mode for \
    'zdharma-continuum/history-search-multi-word' \
    'zsh-users/zsh-syntax-highlighting' \
    'zsh-users/zsh-completions' \
    'migutw42/zsh-fzf-ghq' \
    'zsh-users/zsh-autosuggestions' \
    'jonmosco/kube-ps1'
autoload -Uz compinit && compinit
