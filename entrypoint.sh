#!/bin/bash
set -e

BASE_BRANCH="remotes/origin/$1"
PATHSPEC=${@:2}
#FORK_POINT_SHA=$(git merge-base --fork-point $BASE_BRANCH || git merge-base $BASE_BRANCH HEAD)
#BASE_BRANCH=origin/master
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
ATTEMPT_REBASE=true

echo ::set-output name=fork_point_sha::$FORK_POINT_SHA

function check() {

  readarray -t changed_paths< <(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATHSPEC | sort -u)

  if [[ -z "$(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATHSPEC)" ]];
  then
#    echo "Detected no changes on $PATHSPEC since $FORK_POINT_SHA"
    echo "$BASE_BRANCH has no incoming changes for '$PATHSPEC'"
    echo ::set-output name=changed::false
  else
#    echo "Detected changes on $PATHSPEC since $FORK_POINT_SHA"
    echo "$BASE_BRANCH has incoming changes for '$PATHSPEC'"
    
    for changed_path in "${changed_paths}"; do
      echo "${changed_path}"
    done

#    if [[ "$ATTEMPT_REBASE" == "true" ]]; then
#      git fetch
#      git rebase "${BASE_BRANCH}"
#    fi

    echo ::set-output name=changed::true
  fi
}

check
