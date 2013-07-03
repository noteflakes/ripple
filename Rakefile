require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'yaml'

yml = YAML.load_file(File.join(File.dirname(__FILE__), "VERSION.yml"))
VERSION = "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"


require 'jeweler2'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "ripple"
  gem.summary = "Ripple is a Lilypond generator."
  gem.description = "Ripple is a Lilypond generator."
  gem.email = "ciconia@gmail.com"
  gem.homepage = "http://github.com/ciconia/ripple"
  gem.authors = ["Sharon Rosner"]
  gem.version = VERSION
  gem.add_dependency('directory_watcher', '>= 1.1.1')
end
Jeweler::RubygemsDotOrgTasks.new


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
  sh "irb -I lib -r ripple.rb"
end

desc "Run specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = ['spec/spec_helper.rb', 'spec/**/*_spec.rb']
end


