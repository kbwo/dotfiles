mkfile() {
 mkdir -p $( dirname "$1") && touch "$1"
}

kb() {
   timestamp=$(date +"%Y%m%d%H%M")

   # $1があったら
   if [ -n "$1" ]; then
     prefix=$1
     new_dir="${KBWO}/${prefix}-${timestamp}"
   else
     prefix=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c6)
     new_dir="${KBWO}/${prefix}-${timestamp}"
   fi

   mkdir -p "$new_dir"

   cd "$new_dir" || {
       echo "Cannot move to the new directory: $new_dir"
       return 1
   }
   git init
}

