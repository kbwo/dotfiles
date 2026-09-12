#!/bin/bash

# ~/dotfiles を cwd として Neovim を開いているときだけ、base.vim (StartDotfilesAutoGit)
# から起動される定期 pull/commit/push スクリプト。
#
# obs-kbwo 向けの auto_git.sh (常に pull -> add -> commit -> push を繰り返すだけ)
# と違い、pull がコンフリクトになったときはそこで自動 resolve をせず、
# pull/commit/push を止めて待機する。手動でコンフリクトを解消したら、
# 次の周期で自動的に定期処理を再開する。

TARGET_DIR="$1"
INTERVAL="${2:-300}"

if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <dir> [interval]"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR does not exist"
    exit 1
fi

cd "$TARGET_DIR" || exit 1

# マージ中 (MERGE_HEAD が存在する) か、コンフリクトで未解決のパスが
# 残っているかを見る。どちらかに該当する間は pull/commit/push を止める。
is_conflicted() {
    if [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
        return 0
    fi
    if git status --porcelain=v1 | grep -qE '^(UU|AA|DD|U[ADU]|A[U]|D[U])'; then
        return 0
    fi
    return 1
}

conflicted=0

while true; do
    cd "$TARGET_DIR" || { sleep "$INTERVAL"; continue; }

    if [ "$conflicted" -eq 1 ]; then
        if is_conflicted; then
            echo "still conflicted in $TARGET_DIR, waiting for manual resolution"
            sleep "$INTERVAL"
            continue
        fi
        echo "conflict in $TARGET_DIR resolved, resuming auto pull/commit/push"
        conflicted=0
    fi

    git pull
    pull_status=$?

    if is_conflicted; then
        echo "merge conflict detected in $TARGET_DIR, pausing auto pull/commit/push until resolved"
        conflicted=1
        sleep "$INTERVAL"
        continue
    fi

    if [ "$pull_status" -ne 0 ]; then
        echo "git pull failed in $TARGET_DIR (non-conflict error), will retry next interval"
        sleep "$INTERVAL"
        continue
    fi

    if [ -n "$(git status --porcelain)" ]; then
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        git add .
        git commit -m "Auto commit: $timestamp"
        git push
        echo "Auto pulled, committed and pushed changes in $TARGET_DIR"
    else
        echo "Pulled from $TARGET_DIR (no local changes)"
    fi

    sleep "$INTERVAL"
done
