require File.expand_path("helper", File.dirname(__FILE__))

# one server
scope do
  setup do |t|
    Tell.new(["server1"])
  end

  test "execute with one command" do |t|
    def t.exec(*args); "file1\nfile2"; end

    out = capture do
      t.execute "ls"
      t.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]
    assert Tell::FORMAT % ["run", "ls"] == lines[1]

    assert "             file1" == lines[2]
    assert "             file2" == lines[3]
  end

  test "execute with two commands" do |t|
    def t.exec(server, cmd)
      case cmd
      when "ls"
        "file1\nfile2"
      when "git pull"
        "Already up to date."
      end
    end

    out = capture do
      t.execute "ls"
      t.execute "git pull"
      t.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]

    assert Tell::FORMAT % ["run", "ls"] == lines[1]
    assert "             file1" == lines[2]
    assert "             file2" == lines[3]

    assert Tell::FORMAT % ["run", "git pull"] == lines[4]
    assert "             Already up to date." == lines[5]
  end
end

# two servers
scope do
  setup do |t|
    Tell.new(["server1", "server2"])
  end

  test "execute" do |t|
    def t.exec(*args); "file1\nfile2"; end

    out = capture do
      t.execute "ls"
      t.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]
    assert Tell::FORMAT % ["run", "ls"] == lines[1]

    assert "             file1" == lines[2]
    assert "             file2" == lines[3]

    assert Tell::FORMAT % ["connect", "server2"] == lines[4]
    assert Tell::FORMAT % ["run", "ls"] == lines[5]

    assert "             file1" == lines[6]
    assert "             file2" == lines[7]
  end
end

# within ruby
scope do
  test "execute with one command" do |t|
    tell = Tell.new(["server1"]) do
      execute "ls"
    end
    def tell.exec(*args); "file1\nfile2"; end

    out = capture do
      tell.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]
    assert Tell::FORMAT % ["run", "ls"] == lines[1]

    assert "             file1" == lines[2]
    assert "             file2" == lines[3]
  end
end

# with a directory
scope do
  test "execute with one command" do |t|
    def t.exec(*args); "file1\nfile2"; end

    out = capture do
      t.directory "/some/path"
      t.execute "ls"
      t.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]
    assert Tell::FORMAT % ["directory", "/some/path"] == lines[1]
    assert Tell::FORMAT % ["run", "ls"] == lines[2]

    assert "             file1" == lines[3]
    assert "             file2" == lines[4]
  end
end

# with a recipe
scope do
  test "runs all commands" do |t|
    def t.exec(_, command)
      case command
      when "git pull" then "Already up to date."
      when "thin restart" then "Restarting... Done."
      else
        raise "Unknown command: #{command}"
      end
    end

    out = capture do
      t.recipe "./test/recipe.sh"
      t.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]

    assert Tell::FORMAT % ["run", "git pull"] == lines[1]
    assert "             Already up to date." == lines[2]

    assert Tell::FORMAT % ["run", "thin restart"] == lines[3]
    assert "             Restarting... Done." == lines[4]
  end
end

# with the experimental recipe syntax
scope do
  test "assigns the server and directory" do
    t = Tell.new

    def t.exec(_, command)
      case command
      when "git pull" then "Already up to date."
      when "thin restart" then "Restarting... Done."
      else
        raise "Unknown command: #{command}"
      end
    end

    out = capture do
      t.recipe "./test/extended-recipe.sh"
      t.run
    end

    lines = out.split("\n")
    assert Tell::FORMAT % ["connect", "server1"] == lines[0]
    assert Tell::FORMAT % ["directory", "/some/path"] == lines[1]

    assert Tell::FORMAT % ["run", "git pull"] == lines[2]
    assert "             Already up to date." == lines[3]

    assert Tell::FORMAT % ["run", "thin restart"] == lines[4]
    assert "             Restarting... Done." == lines[5]
  end
end