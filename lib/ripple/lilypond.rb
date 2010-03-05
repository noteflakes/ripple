class LilypondError < RuntimeError
end

module Ripple
  module Lilypond
    def self.delete_ps_file(fn)
      FileUtils.rm("#{fn}.ps") rescue nil
    end
    
    def self.delete_pdf_and_ps_files(fn)
      FileUtils.rm("#{fn}.ps") rescue nil
      FileUtils.rm("#{fn}.pdf") rescue nil
    end
    
    def self.cmd(config)
      File.join(config["lilypond_dir"], config["lilypond_cmd"])
    end
    
    def self.run(args, config)
      IO.popen("#{cmd(config)} #{args}", 'w+') {}
      case $?.exitstatus
      when nil:
        puts
        puts "Interrupted by user"
        exit
      when 0: # success, do nothing
      else
        raise LilypondError, "#{cmd(config)} #{args}"
      end
    end
    
    def self.open(fn, config)
      if config["open_in_background"]
        system "open -g #{fn}"
      else
        system "open #{fn}"
      end
    end
    
    def self.make_pdf(ly_file, pdf_file, config)
      run("--pdf -o \"#{pdf_file}\" \"#{ly_file}\"", config)
      delete_ps_file(pdf_file)
      open("#{pdf_file}.pdf", config) if config["open_target"]
    end
    
    def self.make_midi(ly_file, midi_file, config)
      run("-o \"#{midi_file}\" \"#{ly_file}\"", config)
      delete_pdf_and_ps_files(midi_file)
      open("#{midi_file}.midi", config) if config["open_target"]
    end
  end
end