# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "formageddon/version"

Gem::Specification.new do |s|
  s.name        = "formageddon"
  s.version     = Formageddon::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andy Ross", "Participatory Politics Foundation"]
  s.email       = ["aross@opencongress.org"]
  s.homepage    = ""
  s.summary     = %q{Formageddon automates webform submission.}
  s.description = %q{Formageddon automates webform submission.}

  s.rubyforge_project = "formageddon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency('mechanize')
  s.add_dependency('haml')
end
