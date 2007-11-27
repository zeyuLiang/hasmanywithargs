require 'rubygems'
require 'rake/rdoctask'

module Dweebd
  module HasManyWithArgs
    VERSION = "0.1"
  end
end

desc "Default task is currently to run all tests"
task :default => :test_all

desc "Run all tests"
task :test_all do
  $: << "#{File.dirname(__FILE__)}/test"
  require 'test/all_tests'
end

desc 'Generate RDoc'
Rake::RDocTask.new do |task|
  task.main = 'README'
  task.title = 'HasManyWithArgs'
  task.rdoc_dir = 'doc'
  task.options << "--line-numbers" << "--inline-source"
  task.rdoc_files.include('README', 'RELEASE', 'COPYING', 'MIT-LICENSE', 'lib/**/*.rb')
end
