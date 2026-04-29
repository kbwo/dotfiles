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
    if [ -n "$1" ] && git remote | grep -qx "$1"; then
        git fetch "$1"
        branch="$(git branch -r --sort=-committerdate --format='%(refname:short)' | grep "^$1/" | fzf --no-sort --prompt="$1 branch> ")"
    else
        git fetch --all --quiet
        branch="${1:-$(git branch -a --sort=-committerdate --format='%(refname:short)' | fzf --no-sort --prompt='branch> ')}"
    fi

    if [ -z "$branch" ]; then
        return 0
    fi

    git -C "$main_wt" config worktree.deployed-branch "$branch"

    local lockfile="$main_wt/.git/gwd.lock"
    printf '%s\n' "$$:$branch" > "$lockfile"

    local remote_name=""
    remote_name="$(echo "$branch" | cut -d'/' -f1)"
    if ! git remote | grep -qx "$remote_name"; then
        remote_name=""
    fi

    local current_commit=""
    local new_commit
    local watching=true

    trap 'watching=false' INT

    while $watching; do
        if [ -n "$remote_name" ]; then
            git fetch "$remote_name" --quiet 2>/dev/null
        fi
        new_commit="$(git rev-parse "$branch" 2>/dev/null)"
        if [ -z "$new_commit" ]; then
            echo "Failed to resolve branch: $branch"
            break
        fi
        if [ "$new_commit" != "$current_commit" ]; then
            echo "Deploying: $branch ($new_commit)"
            if ! git -C "$main_wt" checkout --detach "$new_commit"; then
                echo "Failed to detach at commit: $new_commit"
                rm -f "$lockfile"
                trap - INT
                return 0
            fi
            current_commit="$new_commit"
        fi
        sleep 1
    done

    rm -f "$lockfile"
    trap - INT
    echo "Stopped watching: $branch"

    local main_branch
    main_branch="$(git -C "$main_wt" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')"

    if [ -z "$main_branch" ]; then
        main_branch="main"
    fi

    echo "Returning to: $main_branch"
    git -C "$main_wt" checkout "$main_branch"
    git -C "$main_wt" pull
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

    gwd "$branch"
}

gwcd() {
    local wt
    wt="$(git worktree list --porcelain \
        | awk '/^worktree /{print $2}' \
        | while read -r path; do
            ct=$(cd "$path" && git log -1 --format=%ct 2>/dev/null)
            printf '%s\t%s\n' "${ct:-0}" "$path"
          done \
        | sort -rn \
        | cut -f2- \
        | fzf --no-sort --prompt='worktree> ')"

    if [ -z "$wt" ]; then
        return 0
    fi

    cd "$wt"
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
