disable -p '#'
set -o vi

# 単語の区切り文字を指定する
autoload -Uz select-word-style
# enable auto completion
autoload -Uz compinit && compinit
_comp_options+=(globdots)
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export GOPATH=$HOME/go
export GIT_EDITOR=nvim
export LDGFLAGS=-L/usr/local/opt/llvm/lib
export LDFLAGS=-L/usr/local/opt/llvm/lib
export CPPFLAGS=-I/usr/local/opt/llvm/include
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export PYENV_ROOT="$HOME/.pyenv"
export CLOUDSDK_PYTHON=python2
export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --files'
export DENO_INSTALL="/home/kodai/.deno"
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/path/to/parent/dir
export PKG_CONFIG_PATH=/opt/homebrew/opt/expat/lib/pkgconfig
export CPPFLAGS=-I/usr/local/opt/llvm/include

export PATH=$PATH:bin
export PATH=$PATH:/usr/local/Cellar/git/X.XX.X/bin
export PATH=$PATH:/bin
export PATH=$PATH:/sbin
export PATH=$PATH:/usr/bin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/opt/llvm/bin
export PATH=$PATH:/Library/Apple/usr/bin
export PATH=$PATH:node_modules/.bin
export PATH=$PATH:./node_modules/.bin
export PATH=$PATH:/opt/homebrew/opt/llvm/bin
export PATH=$PATH:/opt/homebrew/opt/expat/bin
export PATH=$PATH:/usr/local/Cellar/git/X.XX.X/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/local/bin
export PATH=$PATH:$HOME/.npm-global/bin
export PATH=$PATH:$HOME/.npm-global
export PATH=$PATH:$HOME/.pyenv/bin
export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/development/flutter/bin
export PATH=$PATH:$HOME/.rbenv/shims
export PATH=$PATH:$HOME/.pyenv/shims
export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/google-cloud-sdk/bin
export PATH=$PATH:$HOME/.composer/vendor/bin
export PATH=$PATH:$DENO_INSTALL/bin
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$PYENV_ROOT/bin
export PATH=$PATH:$DENO_INSTALL/bin
export VOLTA_HOME=$HOME/.volta
export PATH=$PATH:$VOLTA_HOME/bin
ctags=/usr/local/bin/ctags
if [ ! -d "$HOME/.zsh" ];then
    mkdir $HOME/.zsh
fi
ZDOTDIR=$HOME/.zsh

alias tod='cd ~/dotfiles'
alias kbwo='cd ~/ghq/github.com/kbwo'
alias ex='exit'
alias :q='exit'
alias so='source'
alias soz='source ~/.zshrc'
alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias rni='npx react-native run-ios'
alias rna='npx react-native run-android'
alias podi='pod install'
alias podu='pod update'
alias y='yarn'
alias ya='yarn add'
alias yi='yarn install'
alias d='docker'
alias dc='docker-compose'
alias gta='git add .'
alias gtc='git commit'
alias gtp='git push'
alias gtb='git branch'
alias gtch='git checkout'
alias gtl='git log'
alias gtd='git diff'
alias gts='git status'
alias gtpl='git pull'
alias gtcl='git clone'
alias gtf='git fetch'
alias gtm='git merge'
alias gtr='git reset'
alias gtrb='git rebase'
alias gtbdm='gtf --prune && gtb --merged | egrep -v "\*|develop|master|main"|xargs git branch -d'
alias ghw='gh repo view --web'
#enable alias after "sudo" command
alias sudo='sudo '
alias intel='arch -x86_64'
alias pconf='p10k configure'
alias nv='eval $EDITOR no-file'

alias -g L='| less'
alias -g G='| grep'

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
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
# use wildcard
setopt extended_glob
setopt globdots
bindkey '^[[Z' reverse-menu-complete

select-word-style default
    # ここで指定した文字は単語区切りとみなされる
    # / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
    zstyle ':zle:*' word-chars " /=;@:{},|"
    zstyle ':zle:*' word-style unspecified
    # 補完で小文字でも大文字にマッチさせる
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*' menu select
    zstyle ':completion:*' special-dirs true
    # ../ の後は今いるディレクトリを補完しない
    zstyle ':completion:*' ignore-parents parent pwd ..
    # sudo の後ろでコマンド名を補完する
    zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
        /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
            # ps コマンドのプロセス名補完
            zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
            ########################################
            # vcs_info
            zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
            zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

            function _update_vcs_info_msg() {
                LANG=en_US.UTF-8 vcs_info
                RPROMPT="${vcs_info_msg_0_}"
            }
        add-zsh-hook precmd _update_vcs_info_msg

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

# C で標準出力をクリップボードにコピーする
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

if [ -d "$HOME/google-cloud-sdk" ];then
		source "$HOME/google-cloud-sdk/path.zsh.inc"
		source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

case "$(uname -s)" in

    Darwin)
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/jdk/Contents/Home
        ;;

    Linux)
        export ANDROID_HOME=$HOME/Android/sdk
        ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        ;;

   *)
   ;;
esac

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zinit load agkozak/zsh-z
compinit -d $ZDOTDIR/compdump
zinit load zdharma/history-search-multi-word
zinit load migutw42/zsh-fzf-ghq
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit ice proto'git' pick'init.sh'
bindkey '^j' autosuggest-accept

eval "$(pyenv init --path)"

### End of Zinit's installer chunk
# if [ -z $TMUX ]; then
# fi
rbenv() {
		unfunction "$0"
		source <(rbenv init -)
		$0 "$@"
}
ghenv() {
    unfunction "$0"
    source <(gh completion -s zsh)
    $0 "$@"
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
