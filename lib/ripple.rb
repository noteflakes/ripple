$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

# rubygems
require 'rubygems'

# core
require 'fileutils'
require 'time'
require 'yaml'

# stdlib

# internal requires
require 'ripple/core_ext'
require 'ripple/syntax'
require 'ripple/figures_syntax'
require 'ripple/templates'
require 'ripple/work'
require 'ripple/part'
require 'ripple/score'
require 'ripple/vocal_score'
require 'ripple/compilation'
require 'ripple/lilypond'
require 'ripple/pdftk'
require 'ripple/generate'

module Ripple
  # Default options. Overriden by values in _config.yml or command-line opts.
  # Strings are used instead of symbols for YAML compatibility.
  CONFIG_FILE = '_ripple.yml'
  
  DEFAULTS = load_yaml(File.join(File.dirname(__FILE__), 'defaults.yml'))
  
  def self.find_config_file(source_dir)
    dir = File.expand_path(source_dir)
    while (fn = File.join(dir, CONFIG_FILE)) && !File.exists?(fn)
      parent = File.expand_path(File.join(dir, '..'))
      return nil if parent == dir
      dir = parent
    end
    fn
  end
  
  def self.configuration(opts = {})
    config = DEFAULTS
    config.deep = true
    if fn = find_config_file(config['source'])
      orig_dir = FileUtils.pwd
      FileUtils.cd File.dirname(fn)
      config = config.deep_merge(load_yaml(fn)).deep_merge(opts)
      # resolve ly, pdf, midi path relative to the config file
      %w[ly_dir pdf_dir midi_dir].each do |d|
        config[d] = File.expand_path(config[d])
      end
      FileUtils.cd orig_dir
      config['config_file_dir'] = File.dirname(fn)
    end
    find_include_files(config)
    config
  end
  
  def self.find_include_files(config)
    
    include_dir = File.join(config['config_file_dir'] || config['source'], "_include")
    return unless File.directory?(include_dir)
    
    config["include"] = []
    config["part_include"] = []
    config["score_include"] = []

    Dir[File.join(include_dir, "**/*.ly")].each do |fn|
      case File.basename(fn)
      when 'part.ly'
        config["part_include"] << File.expand_path(fn)
      when 'score.ly'
        config["score_include"] << File.expand_path(fn)
      else
        config["include"] << File.expand_path(fn)
      end
    end
    
    config["include"].uniq!
    config["part_include"].uniq!
    config["score_include"].uniq!
  end
  
  def self.process(opts = {})
    works(configuration(opts)).each {|w| w.process}
  end
  
  def self.works(config)
    paths = Dir[File.join(config['source'], "**/_work.yml")].
      map {|fn| Work.new(File.dirname(fn), config)}
  end
  
  def self.format_movement_title(mvt)
    if mvt =~ /^(\d+)\-(.+)$/
      num = $1.to_i
      name = $2.gsub("-", " ").gsub(/\b('?[a-z])/) {$1.capitalize}
      "#{num}. #{name}"
    else
      mvt
    end
  end

  def self.version
    yml = load_yaml(File.join(File.dirname(__FILE__), *%w[.. VERSION.yml]))
    "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
  end
end
