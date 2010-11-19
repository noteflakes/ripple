# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ripple}
  s.version = "0.8.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sharon Rosner"]
  s.date = %q{2010-11-20}
  s.default_executable = %q{ripple}
  s.description = %q{Ripple is a Lilypond generator.}
  s.email = %q{ciconia@gmail.com}
  s.executables = ["ripple"]
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "alternative_figures_syntax",
     "bin/ripple",
     "examples/simple/_work.yml",
     "examples/simple/basse.rpl",
     "examples/simple/dessus.rpl",
     "lib/defaults.yml",
     "lib/ripple.rb",
     "lib/ripple/compilation.rb",
     "lib/ripple/core_ext.rb",
     "lib/ripple/figures_syntax.rb",
     "lib/ripple/generate.rb",
     "lib/ripple/lilypond.rb",
     "lib/ripple/part.rb",
     "lib/ripple/score.rb",
     "lib/ripple/syntax.rb",
     "lib/ripple/templates.rb",
     "lib/ripple/templates/combined.ly",
     "lib/ripple/templates/figures.ly",
     "lib/ripple/templates/keyboard_part.ly",
     "lib/ripple/templates/lyrics.ly",
     "lib/ripple/templates/movement.ly",
     "lib/ripple/templates/part.ly",
     "lib/ripple/templates/score.ly",
     "lib/ripple/templates/staff.ly",
     "lib/ripple/templates/tacet.ly",
     "lib/ripple/vocal_score.rb",
     "lib/ripple/work.rb",
     "ripple.gemspec",
     "spec/core_ext_spec.rb",
     "spec/figures_syntax_spec.rb",
     "spec/rendering_spec.rb",
     "spec/spec_helper.rb",
     "spec/syntax_spec.rb"
  ]
  s.homepage = %q{http://github.com/ciconia/ripple}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ripple}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ripple is a Lilypond generator.}
  s.test_files = [
    "spec/core_ext_spec.rb",
     "spec/figures_syntax_spec.rb",
     "spec/rendering_spec.rb",
     "spec/spec_helper.rb",
     "spec/syntax_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<directory_watcher>, [">= 1.1.1"])
    else
      s.add_dependency(%q<directory_watcher>, [">= 1.1.1"])
    end
  else
    s.add_dependency(%q<directory_watcher>, [">= 1.1.1"])
  end
end

