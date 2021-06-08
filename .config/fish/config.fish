set fish_greeting ""
fish_vi_key_bindings
set -gx  LC_ALL en_US.UTF-8

# # theme
set -g theme_color_scheme nord
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_powerline_fonts no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias tod "cd ~/dotfiles"

alias .. 'cd ..'

alias ex 'exit'
alias :q 'exit'
alias so 'source'

alias la 'ls -a'
alias ll 'ls -l'

alias rm 'rm -i'
alias cp 'cp -i'
alias mv 'mv -i'

alias mkdir 'mkdir -p'

# react native
alias rni 'npx react-native run-ios'
alias rna 'npx react-native run-android'
alias podi 'pod install'
alias podu 'pod update'

# yarn
alias y 'yarn'
alias ya 'yarn add'
alias yi 'yarn install'

# docker
alias d 'docker'
alias dc 'docker-compose'

# git
alias gta 'git add .'
alias gtc 'git commit'
alias gtp 'git push'
alias gtb 'git branch'
alias gtch 'git checkout'
alias gtl 'git log'
alias gtd 'git diff'
alias gts 'git status'
alias gtpl 'git pull'
alias gtcl 'git clone'
alias gtf 'git fetch'
alias gtm 'git merge'
alias gtr 'git reset'
alias gtrb 'git rebase'

alias gtbdm 'gtf --prune && gtb --merged | egrep -v "\*|develop|master|main"|xargs git branch -d'

#github
alias ghw 'gh repo view --web'

alias intel 'arch -x86_64'
# sudo の後のコマンドでエイリアスを有効にする
alias sudo 'sudo '

alias nv 'eval $EDITOR no-file'

# set -gx EDITOR nvim
set -g DEMO_INSTALL $HOME/deno
set -g GOPATH $HOME/go

switch (uname)
  case Darwin
    # source (dirname (status --current-filename))/config-osx.fish
    set -g ANDROID_HOME $HOME/Library/Android/sdk
    set -g JAVA_HOME /Library/Java/JavaVirtualMachines/jdk-13.0.2.jdk/Contents/Home
  case Linux
    set -g ANDROID_HOME $HOME/Android/sdk
  case '*'
    # source (dirname (status --current-filename))/config-windows.fish
end

set -gx PATH bin $PATH
set -gx PATH $HOME/bin $PATH
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.npm-global $PATH
set -gx PATH /usr/local/Cellar/git/X.XX.X/bin $PATH
set -gx PATH $HOME/google-cloud-sdk/bin:/usr/local/bin $PATH
set -gx PATH $HOME/.composer/vendor/bin $PATH
set -gx PATH /bin $PATH
set -gx PATH /sbin $PATH
set -gx PATH /usr/bin $PATH
set -gx PATH /usr/sbin $PATH
set -gx PATH /usr/local/bin $PATH
set -gx PATH /usr/local/sbin $PATH
set -gx PATH /usr/local/go/bin $PATH
set -gx PATH /Library/Apple/usr/bin $PATH
set -gx PATH node_modules/.bin $PATH
set -gx PATH $HOME/.npm-global/bin $PATH
set -gx PATH $HOME/.npm-global $PATH
set -gx PATH $HOME/.pyenv/bin $PATH
set -gx PATH $HOME/flutter/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/development/flutter/bin $PATH
set -gx PATH $DENO_INSTALL/bin $PATH
set -gx PATH $ANDROID_HOME/emulator $PATH
set -gx PATH $ANDROID_HOME/tools $PATH
set -gx PATH $ANDROID_HOME/tools/bin $PATH
set -gx PATH $ANDROID_HOME/platform-tools $PATH
set -gx PATH $ANDROID_HOME/emulator $PATH
set -gx PATH $JAVA_HOME/bin $PATH
set -gx PATH /usr/local/opt/llvm/bin $PATH
set -gx PATH $HOME/.rbenv/shims $PATH
set -gx PATH $HOME/.pyenv/shims $PATH
set -gx PATH $GOPATH/bin $PATH
set -gx PATH /opt/homebrew/opt/llvm/bin $PATH

set -g CLOUDSDK_PYTHON python2
set -g FZF_DEFAULT_COMMAND 'rg --hidden --no-ignore --files'

set -g LDGFLAGS -L/usr/local/opt/llvm/lib
# set -g LDGFLAGS -L/opt/homebrew/opt/llvm/lib -Wl,-rpath,/opt/homebrew/opt/llvm/lib
set -g CPPFLAGS -I/usr/local/opt/llvm/include

set -g XDG_CONFIG_HOME $HOME/.config
set -g XDG_CACHE_HOME $HOME/.cache

status --is-interactive; and . (pyenv init --no-rehash -|psub)
status --is-interactive; and . (rbenv init --no-rehash -|psub)
