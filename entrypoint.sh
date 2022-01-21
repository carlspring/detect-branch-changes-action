#!/bin/bash
set -e

BASE_BRANCH="remotes/origin/$1"
PATHSPEC=${@:2}
#FORK_POINT_SHA=$(git merge-base --fork-point $BASE_BRANCH || git merge-base $BASE_BRANCH HEAD)
#BASE_BRANCH=origin/master
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo ::set-output name=fork_point_sha::$FORK_POINT_SHA

function check() {

  if [[ -z "$(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATH_SPEC)" ]];
  then
#    echo "Detected no changes on $PATHSPEC since $FORK_POINT_SHA"
    echo "$BASE_BRANCH has no incoming changes for '$PATH_SPEC'"
    echo ::set-output name=changed::false
  else
#    echo "Detected changes on $PATHSPEC since $FORK_POINT_SHA"
    echo "$BASE_BRANCH has incoming changes for '$PATH_SPEC'"
    echo ::set-output name=changed::true
  fi
}

check
