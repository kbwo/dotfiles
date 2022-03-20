zinit light zsh-users/zsh-autosuggestions
function navi-find() {
  navi --finder 'fzf'
}
bindkey '^j' autosuggest-accept
zle -N navi-findvi --finder 'fzf'
bindkey '^e' navi-find
zinit wait lucid light-mode for \
    'zdharma-continuum/history-search-multi-word' \
    'zdharma-continuum/fast-syntax-highlighting' \
    'zsh-users/zsh-completions' \
    'migutw42/zsh-fzf-ghq' \
    'agkozak/zsh-z' \
    'zsh-users/zsh-autosuggestions'
