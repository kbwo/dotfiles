zinit light zsh-users/zsh-autosuggestions
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
    'zsh-users/zsh-autosuggestions'
