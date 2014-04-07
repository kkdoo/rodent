# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rodent/version'

Gem::Specification.new do |s|
  s.name        = 'rodent'
  s.version     = Rodent::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Artem Maschenko']
  s.email       = ['artem.maschenko@gmail.com']
  s.homepage    = 'https://github.com/kkdoo/rodent'
  s.summary     = 'Framework for micro services'
  s.description = 'Rodent is an open source asynchronous framework for Micro Service Architecture (MSA). It is a lightweight and designed to easily develop APIs. Main goals is scaling, simplicity and perfomance.'
  s.license     = 'MIT'

  s.rubyforge_project = 'rodent'

  s.required_ruby_version = '>=1.9.2'

  s.add_runtime_dependency 'multi_json', '~> 1.9.2'
  s.add_runtime_dependency 'goliath', '~> 1.0.3'
  s.add_runtime_dependency 'amqp', '~> 1.3.0'
  s.add_runtime_dependency 'em-synchrony', '~> 1.0.3'
  s.add_runtime_dependency 'bson_ext', '~> 1.10.0'

  s.add_development_dependency 'rake', '~> 10.2.2'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'em-http-request', '~> 1.1.1'
  s.add_development_dependency 'rack-test', '~> 0.6.2'
  s.add_development_dependency 'evented-spec', '~> 0'
  s.add_development_dependency 'redcarpet', '~> 3.1.1'
  s.add_development_dependency 'yard', '~> 0.8.7.3'

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
