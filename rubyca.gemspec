# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rubyca/version"

Gem::Specification.new do |s|
  s.name        = "rubyca"
  s.version     = RubyCA::VERSION
  s.authors     = ["Holger Just"]
  s.email       = ["hjust@meine-er.de"]
  s.homepage    = "https://github.com/meineerde/rubyca"
  s.summary     = "A simple certificate authority"
  s.description = "This project aims to provide all necessary tools for embedding a simple certificate authority (CA) into your applications."

  s.rubyforge_project = "rubyca"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
