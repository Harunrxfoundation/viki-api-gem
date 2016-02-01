# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "viki/version"

Gem::Specification.new do |s|
  s.name        = "viki-api"
  s.version     = Viki::VERSION
  s.authors     = ["Albert Callarisa Roca", "Fadhli Rahim", "Nuttanart Pornprasitsakul", "Tang Chin Yong", "Etan Le", "Sunjin Lee", "Ryo Chikazawa", "Aysha Anggraini", "Swapnil Kumar"]
  s.email       = ["engineering@viki.com"]
  s.homepage    = "http://dev.viki.com"
  s.summary     = "A thin wrapper around the Viki V4/V5 API"
  s.description = "Official ruby wrapper to access the Viki V4 API and some supported V5 API."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency "rspec", "= 2.13.0"
  s.add_development_dependency "webmock", "~> 1.12.3"
  s.add_development_dependency "timecop", "~> 0.5"

  s.add_runtime_dependency     "oj", ">= 2.0"
  s.add_runtime_dependency     "typhoeus", "= 0.6.9"
  s.add_runtime_dependency     "ethon", "= 0.7.1"
  s.add_runtime_dependency     "addressable", ">= 2.3"
  s.add_runtime_dependency     "viki_utils", "0.0.9"
end
