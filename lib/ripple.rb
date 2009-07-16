$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

# rubygems
require 'rubygems'

# core
require 'fileutils'
require 'time'
require 'yaml'

# stdlib

# internal requires
# require 'ripple/core_ext'
require 'ripple/work'

module Ripple
  # Default options. Overriden by values in _config.yml or command-line opts.
  # Strings are used instead of symbols for YAML compatibility.
  DEFAULTS = {
    'auto'         => false,
    'source'       => '.',
    'ly_dir'       => File.join('.', '_ly'),
    'pdf_dir'      => File.join('.', '_pdf')
  }

  # Generate a Ripple configuration Hash by merging the default options
  # with anything in _info.yml, and adding the given options on top
  #   +override+ is a Hash of config directives
  #
  # Returns Hash
  def self.configuration(override)
    # _config.yml may override default source location, but until
    # then, we need to know where to look for _config.yml
    source = override['source'] || Ripple::DEFAULTS['source']

    # Get configuration from <source>/_info.yml
    config = {}
    config_file = File.join(source, '_info.yml')
    begin
      config = YAML.load_file(config_file)
      puts "Configuration from #{config_file}"
    rescue => err
      puts "WARNING: Could not read configuration. Using defaults (and options)."
      puts "\t" + err
    end

    # Merge DEFAULTS < _config.yml < override
    Ripple::DEFAULTS.deep_merge(config).deep_merge(override)
  end

  def self.version
    yml = YAML.load(File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION.yml])))
    "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
  end
end
