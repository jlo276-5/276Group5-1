#! /bin/bash

set -e
git push -f heroku-faye `git subtree split --prefix StuHub-Faye develop`:master
