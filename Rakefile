lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rake/testtask'
require 'rake/clean'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'bbmb/version'

task :default => :test

# dependencies are now declared in bbmb.gemspec

desc 'Offer a gem task like hoe'
task :gem => :build do
  Rake::Task[:build].invoke
end

task :spec => :clean
CLEAN.include FileList['pkg/*.gem']

# rspec
RSpec::Core::RakeTask.new(:spec)

# unit test
dir = File.dirname(__FILE__)
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = Dir.glob("#{dir}/test/**/test_*.rb")
  t.warning = false
  t.verbose = false
end
