export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export LANG=en_US.UTF-8
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/path/to/parent/dir
autoload -Uz colors
colors
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

PROMPT="%{${fg[green]}%}[%n@%m]%{${reset_color}%} %~
%# "

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

########################################
# 補完
# 補完機能を有効に
autoload -Uz compinit
compinit

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# sudo の後ろでコマンド名を補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                   /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'


########################################
# vcs_info
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

zstyle ':vcs_info:*' formats '%F{green}(%s)-[%b]%f'
zstyle ':vcs_info:*' actionformats '%F{red}(%s)-[%b|%a]%f'

function _update_vcs_info_msg() {
    LANG=en_US.UTF-8 vcs_info
    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg

# vim key bindings
set -o vi

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# Ctrl+Dでzshを終了しない
setopt ignore_eof

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd
# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

# ^R で履歴検索をするときに * でワイルドカードを使用出来るようにする
bindkey '^R' history-incremental-pattern-search-backward

alias ex='exit'
alias so='source'

alias la='ls -a'
alias ll='ls -l'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias mkdir='mkdir -p'

# react native
alias rni='npx react-native run-ios'
alias rna='npx react-native run-android'
alias podi='pod install'
alias podu='pod update'

# yarn
alias y='yarn'
alias ya='yarn add'
alias yi='yarn install'

# npm
alias npi='npm install'
alias npr='npm run'

# docker
alias dce='docker exec -it  bash'
alias dcr='docker run'
alias dcc='docker-compose'

# git
alias gta='git add -A'
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

alias gtbdm='gtf --prune && gtb --merged | egrep -v "\*|develop|master|main"|xargs git branch -d'

#github
alias ghw='gh repo view --web'
# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

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

# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        #Linux用の設定
        alias ls='ls -F --color=auto'
        ;;
esac

# vim:set ft=zsh:
PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH=$PATH:./node_modules/.bin

#python
export PATH=/usr/local/bin:$PATH

# NPM global installs
export PATH=$PATH:~/.npm-global/bin

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kbohead/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kbohead/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kbohead/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kbohead/google-cloud-sdk/completion.zsh.inc'; fi
export PATH=/usr/local/Cellar/git/X.XX.X/bin:/Users/kbohead/google-cloud-sdk/bin:/usr/local/bin:/Users/kbohead/.composer/vendor/bin:/Users/kbohead/google-cloud-sdk/bin:/usr/local/bin:/Users/kbohead/.composer/vendor/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/go/bin:/Library/Apple/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:./node_modules/.bin:/Users/kbohead/.npm-global/bin:/Users/kbohead/go/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:./node_modules/.bin:/Users/kbohead/.npm-global/bin:/Users/kbohead/go/bin

# rust path
export PATH=$HOME/.cargo/bin:$PATH
ctags=/usr/local/bin/ctags

# flutter
export PATH=$PATH:~/flutter/bin

eval "$(gh completion -s zsh)"
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:/Users/kbohead/Library/Android/sdk/platform-tools
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
export CLOUDSDK_PYTHON=python2
