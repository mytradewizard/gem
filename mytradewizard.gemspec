# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mytradewizard/version'

Gem::Specification.new do |gem|
  gem.name          = "mytradewizard"
  gem.version       = MyTradeWizard::VERSION
  gem.authors       = ["mytradewizard"]
  gem.email         = ["zack@mytradewizard.com"]
  gem.description   = "Helpers for CME Group, Interactive Brokers, and Yahoo Finance"
  gem.summary       = "My Trade Wizard"
  gem.homepage      = ""
  
  gem.add_development_dependency "rspec", "~> 2.6"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "aruba"
  
  gem.add_dependency "ib-ruby", "~> 0.9"
  gem.add_dependency "activesupport", "3.2.14"
  gem.add_dependency "activemodel", "3.2.14"
  gem.add_dependency "builder", "~> 3.0.0"
  gem.add_dependency "arel", "~> 3.0.2"
  gem.add_dependency "tzinfo", "~> 0.3.29"
  gem.add_dependency "nokogiri"
  gem.add_dependency "thor"
  gem.add_dependency "gmail"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
