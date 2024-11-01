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

colortest() {
  local color escapes intensity style
  echo "NORMAL bold  dim   itali under rever strik  BRIGHT bold  dim   itali under rever strik"
  for color in $(seq 0 7); do
    for intensity in 3 9; do  # normal, bright
      escapes="${intensity}${color}"
      printf '\e[%sm\\e[%sm\e[0m ' "$escapes" "$escapes" # normal
      for style in 1 2 3 4 7 9; do  # bold, dim, italic, underline, reverse, strikethrough
        escapes="${intensity}${color};${style}"
        printf '\e[%sm\\e[%sm\e[0m ' "$escapes" "$style"
      done
      echo -n " "
    done
    echo
  done
  echo -n "TRUECOLOR "
  awk 'BEGIN{
    columns = 78;
    step = columns / 6;
    for (hue = 0; hue<columns; hue++) {
      x = (hue % step) * 255 / step;
      if (hue < step) {
        r = 255; g = x; b = 0;
      } else if (hue < step*2) {
        r = 255-x; g = 255; b = 0;
      } else if (hue < step*3) {
        r = 0; g = 255; b = x;
      } else if (hue < step*4) {
        r = 0; g = 255-x; b = 255;
      } else if (hue < step*5) {
        r = x; g = 0; b = 255;
      } else {
        r = 255; g = 0; b = 255-x;
      }
      printf "\033[48;2;%d;%d;%dm", r, g, b;
      printf "\033[38;2;%d;%d;%dm", 255-r, 255-g, 255-b;
      printf " \033[0m";
    }
    printf "\n";
  }'
}

export COLORTERM=truecolor
