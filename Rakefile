require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

require 'rspec/core'
require 'rspec/core/rake_task'

#Goliath.run_app_on_exit = false
 
task default: :spec
 
desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run RSpec with code coverage'
task :cov do
  ENV['COVERAGE'] ||= 'true'
  Rake::Task['spec'].invoke
end
