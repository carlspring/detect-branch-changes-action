# Detect Branch Changes

This is a GitHub Action allows you to detect all changes in a branch.
This is done by detecting the fork-point of the current branch with the
repo's main branch.

## Inputs

- `base_branch` - Branch where the fork-point will be found on. Defaults to the repo's default_branch.
- `pathspec` - Which paths should be considered to detect changes on. This path spec must be compattible with the `git diff` command.

## Outputs

- `changed` - Returns `"true"` or `"false"` if files where changed on since the current branche forked from `base_branch`
- `fork_point_sha` - The commit sha that is considered the fork point between this branch and and the `base_branch`

## Usage

## Detect all changes (default behaviour)

```yaml
- uses: younited/detect-branch-changes-action@v0.1.1
```

## Detect changes in different root folders

```yaml
- uses: younited/detect-branch-changes-action@v0.1.1
  with:
    pathspec: "application configs"
```

## Detect file changes

```yaml
- uses: younited/detect-branch-changes-action@v0.1.1
  with:
    pathspec: "a/dee/nested/folder/*.rb"
```

## Detect based on an other branch

```yaml
- uses: younited/detect-branch-changes-action@v0.1.1
  with:
    base_branch: "hotfix-147"
```
