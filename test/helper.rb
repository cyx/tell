require "cutest"
require "stringio"

require File.expand_path("../lib/tell", File.dirname(__FILE__))

def capture
  begin
    out, $stdout = $stdout, StringIO.new
    yield
  ensure
    out, $stdout = $stdout, out
  end

  return out.string
end