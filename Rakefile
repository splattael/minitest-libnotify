require "bundler/gem_tasks"

require 'rdoc/task'

task :default => :test

desc "No tests, sorry :-("
task :test do
  abort "No tests, sorry :-("
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = "doc"
end
