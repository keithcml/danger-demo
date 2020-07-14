#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

git fetch --tags

tag_pattern='staging/*'
if [ "$BRANCH_NAME" = "trunk" ]; then
  tag_pattern='staging/*'
else
  tag_pattern='release/*'
fi

tags=$(git tag -l $tag_pattern --sort=-creatordate)
git_log=""
version_tag=""

for line in $tags; do
  if [ -z "$tag_new" ]
  then
    tag_new=HEAD
    tag_prev=$line
  else
    tag_new=$tag_prev
    tag_prev=$line

    version_tag=$tag_new
    git log $tag_new --not $tag_prev --no-merges --pretty=format:"%s" > git_log.txt
    git_log=$(git log $tag_new --not $tag_prev --no-merges --pretty=format:"%s")
    ruby process_release_note.rb
    rm git_log.txt
    break
  fi
done
