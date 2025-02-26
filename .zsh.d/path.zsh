export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export GOPATH=$HOME/go
export GIT_EDITOR=nvim
# export LDGFLAGS=-L/usr/local/opt/llvm/lib
# export LDFLAGS=-L/usr/local/opt/llvm/lib
# export CPPFLAGS=-I/usr/local/opt/llvm/include
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --files'
export DENO_INSTALL=$HOME/.deno
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/path/to/parent/dir
export PKG_CONFIG_PATH=/opt/homebrew/opt/expat/lib/pkgconfig
export BUN_INSTALL="$HOME/.bun"

# export CPPFLAGS=-I/usr/local/opt/llvm/include
export GHQ_ROOT=$GOPATH/projects
export KBWO=$GHQ_ROOT/github.com/kbwo

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
export PATH=$PATH:./vendor/bin
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:/opt/homebrew/opt/llvm/bin
export PATH=$PATH:/opt/homebrew/opt/expat/bin
export PATH=$PATH:/usr/local/Cellar/git/X.XX.X/bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/local/bin
export PATH=$PATH:$HOME/.npm-global/bin
export PATH=$PATH:$HOME/.npm-global
export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/development/flutter/bin
export PATH=$PATH:$HOME/flutter/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/google-cloud-sdk/bin
export PATH=$PATH:$HOME/.composer/vendor/bin
export PATH=$PATH:$DENO_INSTALL/bin
export PATH=$PATH:$HOME/$ANDROID_HOME/emulator
export PATH=$PATH:$HOME/$ANDROID_HOME/tools
export PATH=$PATH:$HOME/$ANDROID_HOME/tools/bin
export PATH=$PATH:$HOME/$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
export PATH=$PATH:$JAVA_HOME/bin
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/opt/homebrew/opt/openssl@3/bin
export VOLTA_HOME=$HOME/.volta
export PATH=$PATH:/opt/homebrew/Cellar
export PATH=$PATH:$VOLTA_HOME/bin
export PATH=$PATH:$HOME/.rbenv/shims
export PATH=$PATH:$HOME/.rye/shims
export PATH=$PATH:$BUN_INSTALL/bin
export PATH=$PATH:$HOME/.night.zig/latest
export PATH=$PATH:$HOME/.night.zig/nz
unset _VOLTA_TOOL_RECURSION

case "$(uname -s)" in

    Darwin)
        export ANDROID_HOME=$HOME/Library/Android/sdk
        export JAVA_HOME=$(/usr/libexec/java_home -v 11)
        ;;

    Linux)
        export ANDROID_HOME=$HOME/Android/Sdk
        ;;

    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        ;;

   *)
   ;;
esac
export PATH="/opt/homebrew/opt/php@7.3/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.3/sbin:$PATH"
export KUBECONFIG=$HOME/.kube/config

