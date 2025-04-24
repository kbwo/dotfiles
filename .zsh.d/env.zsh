# カレントディレクトリの ./.kbwo/.env.sh を読み込む関数
source_kbwo_env() {
  local env_file="${PWD}/.kbwo/env.sh"
  [[ -f $env_file ]] && source $env_file
}

# シェル起動時に一度実行
source_kbwo_env

# cd したときにも再読み込みしたい場合
autoload -Uz add-zsh-hook
add-zsh-hook chpwd source_kbwo_env
