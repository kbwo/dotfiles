mkfile() {
 mkdir -p $( dirname "$1") && touch "$1"
}

kb() {
   timestamp=$(date +"%Y%m%d%H%M")

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

rmkb() {
    if [ -z "$1" ]; then
        echo "Usage: rmkb <keyword>"
        return 1
    fi
    find "$KBWO" -maxdepth 1 -type d -name "*$1*" -exec rm -rf {} +
}

gwd() {
    local main_wt
    main_wt="$(git worktree list --porcelain | head -n 1 | sed 's/^worktree //')"

    if [ -z "$main_wt" ]; then
        echo "No git worktree found."
        return 1
    fi

    local branch
    branch="$(git branch -a --format='%(refname:short)' | fzf --prompt='branch> ')"

    if [ -z "$branch" ]; then
        return 0
    fi

    local commit
    commit="$(git rev-parse "$branch")"

    git -C "$main_wt" checkout --detach "$commit" && \
        git -C "$main_wt" config worktree.deployed-branch "$branch"
}

gwr() {
    local main_wt
    main_wt="$(git worktree list --porcelain | head -n 1 | sed 's/^worktree //')"

    if [ -z "$main_wt" ]; then
        echo "No git worktree found."
        return 1
    fi

    local branch
    branch="$(git -C "$main_wt" config worktree.deployed-branch)"

    if [ -z "$branch" ]; then
        echo "No deployed branch found. Run gwd first."
        return 1
    fi

    local commit
    commit="$(git rev-parse "$branch")"

    echo "Refreshing: $branch ($commit)"
    git -C "$main_wt" checkout --detach "$commit"
}

gwb() {
    local main_wt
    main_wt="$(git worktree list --porcelain | head -n 1 | sed 's/^worktree //')"

    if [ -z "$main_wt" ]; then
        echo "No git worktree found."
        return 1
    fi

    local main_branch
    main_branch="$(git -C "$main_wt" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')"

    if [ -z "$main_branch" ]; then
        main_branch="main"
    fi

    git -C "$main_wt" checkout "$main_branch"
}
