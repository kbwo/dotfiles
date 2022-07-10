pyenv() {
		unfunction "$0"
		source <(pyenv init --path)
		$0 "$@"
}
