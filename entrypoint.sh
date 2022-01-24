#!/bin/bash

bash --version

exit 0

set -e

BASE_BRANCH="remotes/origin/$1"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
FORK_POINT_SHA=$(git merge-base --fork-point $BASE_BRANCH || git merge-base $BASE_BRANCH HEAD)
#PATHSPEC=${@:2}
#BASE_BRANCH=origin/master
ATTEMPT_REBASE=true

echo ::set-output name=fork_point_sha::$FORK_POINT_SHA

function check() {


  echo "Version 1.0.0"
  echo "Bash version:   `bash --version`"
  echo "-------------"
  echo "BASE_BRANCH:    ${BASE_BRANCH}"
  echo "CURRENT_BRANCH: ${CURRENT_BRANCH}"
  echo "FORK_POINT_SHA: ${FORK_POINT_SHA}"
  echo "PATHSPEC:       ${PATHSPEC}"
  echo "ATTEMPT_REBASE: ${ATTEMPT_REBASE}"
  echo "-------------"

  readarray -t changed_paths< <(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATHSPEC | sort -u)

  if [[ -z "$(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATHSPEC)" ]];
  then
    echo "$BASE_BRANCH has no incoming changes for '${PATHSPEC}'"
    echo ::set-output name=changed::false
  else
    echo "The $BASE_BRANCH upstream branch has incoming changes, (PATHSPEC: '${PATHSPEC}'):"
    
    for changed_path in "${changed_paths}"; do
      echo " > ${changed_path}"
    done

#    if [[ "$ATTEMPT_REBASE" == "true" ]]; then
#      git fetch
#      git rebase "${BASE_BRANCH}"
#    fi

    echo ::set-output name=changed::true
  fi
}

check
