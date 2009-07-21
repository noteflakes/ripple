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
require 'ripple/work'
require 'ripple/part'
require 'ripple/score'
require 'ripple/templates'
require 'ripple/lilypond'

module Ripple
  # Default options. Overriden by values in _config.yml or command-line opts.
  # Strings are used instead of symbols for YAML compatibility.
  CONFIG_FILE = '_ripple.yml'
  AUTO = 'auto'
  SOURCE = 'source'
  LY_DIR = 'ly_dir'
  PDF_DIR = 'pdf_dir'
  
  DEFAULTS = {
    AUTO      => false,
    SOURCE    => '.',
    LY_DIR    => File.join('.', '_ly'),
    PDF_DIR   => File.join('.', '_pdf')
  }
  
  def self.configuration(opts = {})
    config = DEFAULTS.merge(opts)
    config_file_path = File.join(config[SOURCE], CONFIG_FILE)
    if File.exists?(config_file_path)
      config.merge!(YAML.load_file(config_file_path))
    end
    
    find_include_files(config)
    config
  end
  
  def self.find_include_files(config)
    include_dir = File.join(config["source"], "_include")
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
    paths = Dir[File.join(config[SOURCE], "**/_work.yml")].
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
    yml = YAML.load(File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION.yml])))
    "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
  end
end
