Rugby - A Ruby IRC Bot
======================

Rugby is an IRC bot in Ruby based on [Cinch](https://github.com/cinchrb/cinch) that provides Google results and memos.

__Installation instructions:__

1. Make sure you have ruby and rubygems installed. You can install the
   dependencies using Bundler (gem install bundler) with a simple
`bundle install`
2. Copy irc.yml.example to irc.yml and edit it to configure the server, nick, and channels you want to
   join.
3. `ruby rugby.rb` to launch!

Make sure you can `require 'net/https'` in an irb session otherwise the
image search will not work. You can get net/https on Ubuntu by
installing `libopenssl-ruby`

Contributing
------------
If you find any bugs or would like to add any features just add a bug
report or pull request.

License
-------
Copyright (c) 2011 Chris Oliver. See LICENSE for details.
