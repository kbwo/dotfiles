ghenv() {
    unfunction "$0"
    source <(gh completion -s zsh)
    $0 "$@"
}
