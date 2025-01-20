ZSHHOME="${HOME}/dotfiles/.zsh.d"

if [ -d $ZSHHOME -a -r $ZSHHOME -a \
     -x $ZSHHOME ]; then
    for i in $ZSHHOME/*; do
        [[ ${i##*/} = *.zsh ]] &&
            [ \( -f $i -o -h $i \) -a -r $i ] && . $i
    done
fi
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f "/Users/kbwo/.ghcup/env" ] && source "/Users/kbwo/.ghcup/env" # ghcup-env
# bun completions
[ -s "/home/kbwo/.bun/_bun" ] && source "/home/kbwo/.bun/_bun"

eval "$(~/.local/bin/mise activate zsh)"

