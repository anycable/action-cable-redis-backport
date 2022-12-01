# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

task default: :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["#{__dir__}/test/**/*_test.rb"]
  t.warning = true
  t.verbose = true
end
