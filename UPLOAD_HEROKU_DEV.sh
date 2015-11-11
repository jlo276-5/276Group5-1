#! /bin/bash

set -e
old_branch=$(git rev-parse --abbrev-ref HEAD)
git checkout develop
./pre-push-dev
git push -f heroku-dev `git subtree split --prefix StuHub develop`:master
git checkout $old_branch
