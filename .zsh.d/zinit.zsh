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
zinit light agkozak/zsh-z
ABBR_USER_ABBREVIATIONS_FILE="${HOME}/dotfiles/.zsh.d/abbreviations"
zinit light olets/zsh-abbr
autoload -Uz compinit && compinit -d ${HOME}/.zcompdump
zinit wait lucid light-mode as'null' \
    atinit'. "$ZDOTDIR/zinit/plugins.zsh"' \
    for 'zdharma-continuum/null'
