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
        if ! new_commit="$(git rev-parse --verify --quiet "${branch}^{commit}")"; then
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
    local wt_data
    wt_data="$(git worktree list --porcelain 2>/dev/null)"

    if [ -z "$wt_data" ]; then
        echo "No git worktrees found."
        return 1
    fi

    # branch shortname -> worktree path (branched worktrees)
    local mapping
    mapping="$(echo "$wt_data" | awk '
        /^worktree / { path = substr($0, 10); branch = "" }
        /^branch /   { branch = substr($0, 8); sub(/^refs\/heads\//, "", branch) }
        /^$/ && path != "" { if (branch != "") print branch "\t" path; path = "" }
        END          { if (path != "" && branch != "") print branch "\t" path }
    ')"

    # detached HEAD worktrees (e.g. main worktree managed by gwd)
    local detached
    detached="$(echo "$wt_data" | awk '
        /^worktree / { path = substr($0, 10); has_branch = 0 }
        /^branch /   { has_branch = 1 }
        /^$/ && path != "" { if (!has_branch) print path; path = "" }
        END          { if (path != "" && !has_branch) print path }
    ')"

    local selected
    selected="$(
        {
            { printf '%s\n' "$mapping"; printf -- '---\n'; git branch -a --sort=-committerdate --format='%(refname:short)'; } | \
            awk -F'\t' '
                /^---$/  { state = 1; next }
                !state   { if ($1 != "") m[$1] = $2; next }
                {
                    b = $1
                    if (b in m && !seen[m[b]]++) { print m[b]; next }
                    sub(/^[^\/]+\//, "", b)
                    if (b in m && !seen[m[b]]++) print m[b]
                }
            '
            printf '%s\n' "$detached"
        } | grep -v '^$' | fzf --prompt='worktree> '
    )"

    if [ -z "$selected" ]; then
        return 0
    fi

    cd "$selected"
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
