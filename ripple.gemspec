# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ripple}
  s.version = "0.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sharon Rosner"]
  s.date = %q{2009-07-16}
  s.default_executable = %q{ripple}
  s.description = %q{Ripple is a lilypond generator.}
  s.email = %q{ciconia@gmail.com}
  s.executables = ["ripple"]
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "bin/ripple",
    "lib/ripple.rb",
    "lib/defaults.yml",
    "lib/ripple/core_ext.rb",
    "lib/ripple/lilypond.rb",
    "lib/ripple/part.rb",
    "lib/ripple/score.rb",
    "lib/ripple/vocal_score.rb",
    "lib/ripple/syntax.rb",
    "lib/ripple/templates.rb",
    "lib/ripple/work.rb",
    "lib/ripple/templates/movement.ly",
    "lib/ripple/templates/staff.ly",
    "lib/ripple/templates/combined.ly",
    "lib/ripple/templates/lyrics.ly",
    "lib/ripple/templates/figures.ly",
    "lib/ripple/templates/tacet.ly",
    "lib/ripple/templates/part.ly",
    "lib/ripple/templates/score.ly"
  ]
  s.homepage = %q{http://github.com/ciconia/ripple}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ripple}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Ripple is a lilypond generator.}
  s.test_files = [
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
  end
end
