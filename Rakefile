#coding: utf-8
require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :build

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/plugin/*.rb']
  test.verbose = true
end

