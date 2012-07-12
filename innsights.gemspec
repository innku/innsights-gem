# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'innsights/version'

Gem::Specification.new do |s|
  s.name        = "innsights"
  s.version     = Innsights::VERSION
  s.authors     = ["Adrian Cuadros"]
  s.email       = ["adrian@innku.com"]
  s.homepage    = "http://github.com/innku/innsights"
  s.summary     = %q{Analytics that measure app metrics with the apps language}
  s.description = %q{Analytics that model your apps metrics and concepts and measure your User engagement}
  s.rubyforge_project = "innsights"
  s.files         = `git ls-files`.split("\n")
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # Runtime dependencies
  s.add_runtime_dependency "rails", '>=3.0.0'
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "ruby-progressbar"
  s.add_runtime_dependency "highline"
  s.add_runtime_dependency "resque"
  s.add_runtime_dependency "delayed_job_active_record"
  s.add_runtime_dependency "daemons"
  
  # Development dependencies
  # s.add_development_dependency "factory_girl_rails"
  
end
