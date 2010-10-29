class Tell
  VERSION = "0.0.1"

  # ANSI Colors for a better user experience.
  # 1;32m - Green
  # 1;37m - White
  FORMAT = "\e[1;32m %10s\e[1;37m  %s"

  attr :servers

  def initialize(servers = [], &block)
    @servers = servers
    @commands = []

    instance_eval(&block) if block_given?
  end

  def execute(command)
    @commands << command
  end

  def run
    silence!

    servers.each do |server|
      log :connect, server

      @commands.each do |command|
        log :run, command

        display exec(server, command)
      end
    end
  end

private
  def log(type, message)
    puts FORMAT % [type, message]
  end

  def exec(server, command)
    `ssh #{server} -- #{command}`
  end

  def display(str, margin = 13)
    puts str.gsub(/^/, " " * margin)
  end

  def silence!
    STDERR.reopen(File.open("/dev/null", "w"))
  end
end