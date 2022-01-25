#!/usr/bin/env bash

set -e

echo "Script version 1.0.0"

echo "-------------"
echo "BASH_VERSION:   ${BASH_VERSION}"

echo "GIT_VERSION:    `git --version`"

DEBUG_MODE="$1"
echo "DEBUG_MODE:     ${DEBUG_MODE}"

ATTEMPT_REBASE="$2"
echo "ATTEMPT_REBASE: ${ATTEMPT_REBASE}"

FAIL_ON_CHANGES="$3"
echo "FAIL_ON_CHANGES (and ATTEMPT_REBASE=false): ${FAIL_ON_CHANGES}"

# The remotes/origin part was previously hardcoded here and removed to allow better testing. 
# If you need it, then put `remotes/origin/branch_name` as part of the `base_branch` input.
BASE_BRANCH="$4"
echo "BASE_BRANCH:    ${BASE_BRANCH}"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "CURRENT_BRANCH: ${CURRENT_BRANCH}"

FORK_POINT_SHA=$(git merge-base --fork-point $BASE_BRANCH || git merge-base $BASE_BRANCH HEAD)
echo "FORK_POINT_SHA: ${FORK_POINT_SHA}"

PATHSPEC=${@:5}
echo "PATHSPEC:       ${PATHSPEC}"

echo "-------------"

echo ::set-output name=fork_point_sha::$FORK_POINT_SHA

function check() {
  [[ "$DEBUG_MODE" == "true" ]] && set -x

  echo ""
  echo "Fetching changed paths..."
  readarray -t changed_paths< <(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATHSPEC | sort -u)
  echo ""

  if [[ -z "$(git diff --name-only $BASE_BRANCH..$CURRENT_BRANCH -- $PATHSPEC)" ]];
  then
    echo "$BASE_BRANCH has no incoming changes for '${PATHSPEC}'"
    echo ""
    echo ::set-output name=changed::false 
    echo ::set-output name=rebased::$ATTEMPT_REBASE
  else
    echo "The $BASE_BRANCH upstream branch has incoming changes, (PATHSPEC: '${PATHSPEC}'):"
    echo ""
    echo ::set-output name=changed::true
    echo ::set-output name=rebased::$ATTEMPT_REBASE

    echo "Detected changes in the following paths:"
    echo "${changed_paths[@]}"
    echo ""

    if [[ "$ATTEMPT_REBASE" == "true" ]]; then
      echo "Attempting rebase using ${BASE_BRANCH}..."
      git fetch
      git rebase "${BASE_BRANCH}"
      echo ""
      echo "Rebase done."
      echo ""
      exit 0
    elif [[ "$FAIL_ON_CHANGES" == "true" ]]; then
      echo "Failing step to prevent further execution (FAIL_ON_CHANGES=$FAIL_ON_CHANGES)."
      exit 1
    else
      echo "Action is configured with fail_on_changes: ${FAIL_ON_CHANGES} and rebase: ${ATTEMPT_REBASE} -- continuing without throwing error."
      exit 0
    fi

    [[ "$DEBUG_MODE" == "true" ]] && set -x

  fi
}

check
