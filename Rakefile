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
  
  puts
  puts "= = = Analyze Ruby Style Guide. = = ="
  sh 'find lib -name "*.rb" -exec rubocop --format html -o "#{path}index_rubocop.html" \;'
  puts "=> Report can be found in #{path}index_rubocop.html"
  puts
  
  puts
  puts "= = = Analysis of cyclomatic complexity = = ="
  sh "saikuro -c -i lib -y 0 -w 11 -e 16 -o #{path}"
  puts "=> Report can be found in #{path}index_cyclo.html"
  puts
  
  puts "= = = Analysis of FLOG (ABC) complexity = = ="
  sh 'find lib -name "*.rb" -exec flog {} -a -b \;'
  puts
  
  puts "= = = Analysis code similarities ('copy & paste') = = ="
  sh 'java -jar /Users/ms1/Programmierung/simian-2.4.0/bin/simian-2.4.0.jar ./**/*.rb'
  puts
  
  puts "= = = Unit Tests to follow... = = ="
  
end