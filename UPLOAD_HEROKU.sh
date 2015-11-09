#! /bin/bash

set -e
old_branch=$(git rev-parse --abbrev-ref HEAD)
git checkout master
./pre-push
git push -f heroku `git subtree split --prefix StuHub master`:master
git checkout $old_branch
