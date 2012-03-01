# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "devise_crowd/version"

Gem::Specification.new do |s|
  s.name        = "devise_crowd"
  s.version     = DeviseCrowd::VERSION
  s.authors     = ["Brandon Turner"]
  s.email       = ["bt@brandonturner.net"]
  s.homepage    = ""
  s.summary     = %q{Crowd authentication for Devise}
  s.description = %q{Crowd authentication for Devise}

  s.rubyforge_project = "devise_crowd"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency %q<simple_crowd>
  s.add_runtime_dependency %q<activesupport>
  s.add_runtime_dependency(%q<devise>, [">= 2.0.4"])
end
