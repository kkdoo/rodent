# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rodent/version'

Gem::Specification.new do |s|
  s.name        = 'rodent'
  s.version     = Rodent::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Artem Maschenko']
  s.email       = ['artem.maschenko@gmail.com']
  s.homepage    = 'http://goliath.io/'
  s.summary     = 'Framework for micro services'
  s.description = s.summary
  s.license     = 'MIT'

  s.rubyforge_project = 'rodent'

  s.required_ruby_version = '>=1.9.2'

  s.add_dependency 'multi_json'
  s.add_dependency 'goliath'
  s.add_dependency 'amqp'
  s.add_dependency 'em-synchrony'

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
