zinit load agkozak/zsh-z
zinit light zsh-users/zsh-autosuggestions
eval "$(navi widget zsh)"
function navi-find() {
  navi --finder 'fzf'
}
bindkey '^j' autosuggest-accept
zle -N navi-find
bindkey '^e' navi-find
zinit wait lucid light-mode for \
    'zdharma-continuum/history-search-multi-word' \
    'zsh-users/zsh-syntax-highlighting' \
    'zsh-users/zsh-completions' \
    'migutw42/zsh-fzf-ghq' \
    'zsh-users/zsh-autosuggestions' \
    'sindresorhus/pure' \
    'jonmosco/kube-ps1' \
    'olets/zsh-abbr'
autoload -Uz compinit && compinit
