rbenv() {
		unfunction "$0"
		source <(rbenv init -)
		$0 "$@"
}
