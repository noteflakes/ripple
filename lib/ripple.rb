$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

# rubygems
require 'rubygems'

# core
require 'fileutils'
require 'time'
require 'yaml'

# stdlib

# internal requires
require 'ripple/work'
require 'ripple/part'
require 'ripple/score'

module Ripple
  # Default options. Overriden by values in _config.yml or command-line opts.
  # Strings are used instead of symbols for YAML compatibility.
  CONFIG_FILE = '_config.yml'
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
    config
  end
  
  def self.process(opts = {})
    works(configuration(opts)).each {|w| w.process}
  end
  
  def self.works(config)
    paths = Dir[File.join(config[SOURCE], "**/_work.yml")].
      map {|fn| Work.new(File.dirname(fn), config)}
  end

  def self.version
    yml = YAML.load(File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION.yml])))
    "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
  end
end
