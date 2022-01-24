#!/bin/bash



set -e

echo "Script version 1.0.0"

echo "--------------------"
echo "BASH_VERSION:   ${BASH_VERSION}"

echo "GIT_VERSION:    `git --version`"

BASE_BRANCH="remotes/origin/$1"
echo "BASE_BRANCH:    ${BASE_BRANCH}"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "CURRENT_BRANCH: ${CURRENT_BRANCH}"

FORK_POINT_SHA=$(git merge-base --fork-point $BASE_BRANCH || git merge-base $BASE_BRANCH HEAD)
echo "FORK_POINT_SHA: ${FORK_POINT_SHA}"

PATHSPEC=${@:2}
echo "PATHSPEC:       ${PATHSPEC}"

ATTEMPT_REBASE=true
echo "ATTEMPT_REBASE: ${ATTEMPT_REBASE}"
echo "-------------"

exit 1

echo ::set-output name=fork_point_sha::$FORK_POINT_SHA

function check() {

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
