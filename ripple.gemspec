# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ripple}
  s.version = "0.1.0"

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
    "lib/ripple/core_ext.rb",
    "lib/ripple/lilypond.rb",
    "lib/ripple/part.rb",
    "lib/ripple/score.rb",
    "lib/ripple/syntax.rb",
    "lib/ripple/templates.rb",
    "lib/ripple/work.rb"
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

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      # s.add_runtime_dependency(%q<RedCloth>, [">= 4.2.1"])
      # s.add_runtime_dependency(%q<liquid>, [">= 1.9.0"])
      # s.add_runtime_dependency(%q<classifier>, [">= 1.3.1"])
      # s.add_runtime_dependency(%q<maruku>, [">= 0.5.9"])
      # s.add_runtime_dependency(%q<directory_watcher>, [">= 1.1.1"])
      # s.add_runtime_dependency(%q<open4>, [">= 0.9.6"])
    else
      # s.add_dependency(%q<RedCloth>, [">= 4.2.1"])
      # s.add_dependency(%q<liquid>, [">= 1.9.0"])
      # s.add_dependency(%q<classifier>, [">= 1.3.1"])
      # s.add_dependency(%q<maruku>, [">= 0.5.9"])
      # s.add_dependency(%q<directory_watcher>, [">= 1.1.1"])
      # s.add_dependency(%q<open4>, [">= 0.9.6"])
    end
  else
    # s.add_dependency(%q<RedCloth>, [">= 4.2.1"])
    # s.add_dependency(%q<liquid>, [">= 1.9.0"])
    # s.add_dependency(%q<classifier>, [">= 1.3.1"])
    # s.add_dependency(%q<maruku>, [">= 0.5.9"])
    # s.add_dependency(%q<directory_watcher>, [">= 1.1.1"])
    # s.add_dependency(%q<open4>, [">= 0.9.6"])
  end
end
