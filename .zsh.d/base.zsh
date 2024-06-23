set -o vi

autoload -Uz select-word-style
# enable auto completion
_comp_options+=(globdots)
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

# enable to display japanese file
setopt print_eight_bit
setopt no_beep
setopt no_flow_control
# disable to fisnish zsh by Ctrl+D
setopt ignore_eof
# code after '#' become comments
setopt interactive_comments
# cd by directory name
setopt auto_cd
# auto pushd on cd
setopt auto_pushd
# don't add duplicate directory
setopt pushd_ignore_dups
setopt SHARE_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
# use wildcard
setopt extended_glob
setopt globdots

select-word-style default
    zstyle ':zle:*' word-chars " /=;@:{},|"
    zstyle ':zle:*' word-style unspecified
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*' menu select
    zstyle ':completion:*' special-dirs true
    zstyle ':completion:*' ignore-parents parent pwd ..
    zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
        /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
            zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
            zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
            zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

            function _update_vcs_info_msg() {
                LANG=en_US.UTF-8 vcs_info
                RPROMPT="${vcs_info_msg_0_}"
            }
        add-zsh-hook precmd _update_vcs_info_msg

bindkey '^R' history-incremental-pattern-search-backward

# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    alias -g C='| putclip'
fi

case ${OSTYPE} in
    darwin*)
        #for macos
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #for linux
        alias ls='ls -F --color=auto'
        ;;
esac
