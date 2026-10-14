### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

ZDOTDIR="${HOME}/dotfiles/.zsh.d"
zinit light sindresorhus/pure
# `memo <text>` でこのシェルの作業メモをプロンプト記号の左に表示する。引数なしで消す。
# pure は PROMPT の最後の改行より後ろを保持して再描画するので、ここで先頭に足せば残る。
memo() { TERM_MEMO=${1:+"%K{208}%F{black}%B ${*//\%/%%} %b%f%k "} }
PROMPT='$TERM_MEMO'$PROMPT
ABBR_USER_ABBREVIATIONS_FILE="${HOME}/dotfiles/.zsh.d/abbreviations"
zinit wait lucid light-mode as'null' \
    atinit'. "$ZDOTDIR/zinit/plugins.zsh"' \
    for 'zdharma-continuum/null'
