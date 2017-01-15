require 'rake/testtask'
require 'rubocop/rake_task'
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

RuboCop::RakeTask.new

RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include('lib')
  rdoc.rdoc_dir = 'doc'
end

task default: :test
task default: :rdoc
task default: :rubocop
