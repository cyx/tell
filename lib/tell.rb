class Tell
  VERSION = "0.0.1"

  GREEN = "\e[1;32m"
  RED   = "\e[1;31m"
  WHITE = "\e[1;37m"

  FORMAT = "\n#{GREEN}%s#{RED}@%s#{WHITE}\n-> %s"

  attr :servers

  def initialize(servers = [], &block)
    @servers = servers
    @commands = []

    instance_eval(&block) if block_given?
  end

  def directory(directory)
    @directory = directory
  end

  def recipe(file)
    File.readlines(file).each do |line|
      next if command = line.strip and command.to_s.empty?

      if command =~ /\A# servers (.*)\z/
        @servers = $1.split(" ")
      elsif command =~ /\A# directory (.*)\z/
        @directory = $1
      else
        execute(command)
      end
    end
  end

  def execute(command)
    @commands << command
  end

  def run
    silence!

    servers.each do |server|
      @commands.each do |command|
        log server, command

        display exec(server, command)
      end
    end
  end

private
  def log(server, command)
    puts FORMAT % [@directory, server, command]
  end

  def exec(server, command)
    `ssh #{server} "#{cwd_and_run(command)}"`
  end

  def cwd_and_run(command)
    cd = "cd #{@directory}" if @directory

    [cd, command].compact.join(" && ")
  end

  def display(str, margin = 3)
    puts str.gsub(/^/, " " * margin)
  end

  def silence!
    STDERR.reopen(File.open("/dev/null", "w"))
  end
end
