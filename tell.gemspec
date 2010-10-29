Gem::Specification.new do |s|
  s.name = "tell"
  s.version = "0.0.1"
  s.summary = %{(T)hin Ruby Secure Sh(ell).}
  s.date = "2010-10-29"
  s.author = "Cyril David"
  s.email = "cyx@pipetodevnull.com"
  s.homepage = "http://github.com/cyx/tell"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.files = ["lib/tell.rb", "README.markdown", "LICENSE", "test/helper.rb", "test/tell_test.rb"]

  s.require_paths = ["lib"]

  s.add_dependency "clap"
  s.add_development_dependency "cutest"
  s.has_rdoc = false
  s.executables.push "tell"
end