Tell
====

Dead simple SSH access using what's already available.

First...
--------

Did you know you can do this?

    $ ssh server1 -- git pull

The command above will connect to server1 (assuming you have something like
that in your SSH config (~/.ssh/config) and execute git pull upon connecting.

What this does?
---------------

It wraps that command and makes it convenient to execute mutiple commands at
once.

Example:
--------

    $ tell server1 -c "git pull" -c "rake cdn:update" -c "thin restart"

You can also execute commands against multiple servers.

    $ tell server1 server2 -c "ls"

Within Ruby?
------------

    require "tell"

    tell = Tell.new(["server1"]) do
      execute "git pull"
      execute "rake cdn:update"
      execute "thin restart"
    end

    tell.run