require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  gem 'jeweler', '>= 0.11.0'
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "ripple"
    s.summary = %Q{Ripple is a lilypond helper.}
    s.email = "ciconia@gmail.com"
    s.homepage = "http://github.com/ciconia/ripple"
    s.description = "Ripple is a lilypond helper."
    s.authors = ["Sharon Rosner"]
    s.rubyforge_project = "ripple"
    # s.add_dependency('RedCloth', '>= 4.0.4')
    # s.add_dependency('liquid', '>= 1.9.0')
    # s.add_dependency('classifier', '>= 1.3.1')
    # s.add_dependency('maruku', '>= 0.5.9')
    # s.add_dependency('directory_watcher', '>= 1.1.1')
    # s.add_dependency('open4', '>= 0.9.6')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler --version '>= 0.11.0'"
  exit(1)
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ripple'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# console

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r ripple.rb"
end
