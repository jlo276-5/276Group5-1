# StuHub [![Build Status](https://magnum.travis-ci.com/jlo276-5/276Group5.svg?token=CpLyiEfLysgyxDPBuw3y&branch=master)](https://magnum.travis-ci.com/jlo276-5/276Group5)
(Sorry, TravisCI build info not public)

This is the repository for StuHub, an online app built using Ruby on Rails and hosted on Heroku.

## Running
This cannot be run properly on a local environment without the appropriate Environment Variables. Contact the developers for those.

Otherwise just clone it or download an archive.

With an appropriate Heroku setup, run `bundle exec puma -C config/puma.rb` inside the StuHub folder.

If you need the chat server, run `bundle exec rackup private_pub.ru -s thin -E production` inside the StuHub-Faye folder as well.

## Issues
Please open an issue for any errors, problems, and suggestions.

## Change Log
[Go to Change Log](StuHub/CHANGES.md)

## Credits
CMPT276 Fall 2015 Group 5
