# encoding: UTF-8

require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

RuboCop::RakeTask.new

desc 'test'
task default: :metrics
task default: :test
task default: :rubocop

desc 'metrics'
task :metrics do
  # path = 'coverage/'
  # puts
  # puts '= = = Analysis of cyclomatic complexity = = ='
  # sh "saikuro -c -i lib -y 0 -w 11 -e 16 -o #{path}"
  # puts '=> Report can be found in #{path}index_cyclo.html'
  # puts
  # puts '= = = Analysis of FLOG (ABC) complexity = = ='
  # sh 'find lib -name "*.rb" -exec flog {} -a -b \;'
  puts

  puts '= = = Analysis of code similarities ("copy & paste") = = ='
  sh 'java -jar /Users/ms1/Programmierung/simian-2.4.0/bin/simian-2.4.0.jar ./**/*.rb'
  puts

  puts '= = = Unit Tests = = ='
end
