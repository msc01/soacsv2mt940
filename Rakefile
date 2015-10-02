require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

desc "test"
task :default => :metrics
task :default => :test

desc "metrics"
task :metrics do
  path = "coverage/"
  
  sh "saikuro -c -i lib -y 0 -w 11 -e 16 -o #{path}"
  puts "=> Analysis of cyclomatic compexity can be found in #{path}index_cyclo.html\n"
  
  sh 'find lib -name "*.rb" -exec flog {} -a -b \;'
  
end