class LilypondError < RuntimeError
end

module Ripple
  module Lilypond
    def self.delete_ps_file(pdf_file)
      FileUtils.rm("#{pdf_file}.ps") rescue nil
    end
    
    def self.run_lilypond(ly_file, pdf_file, config)
      IO.popen("ly --pdf -o \"#{pdf_file}\" \"#{ly_file}\"", 'w+') {}
      raise LilypondError unless $?.exitstatus == 0
    end
    
    def self.process(ly_file, pdf_file, config)
      run_lilypond(ly_file, pdf_file, config)
      delete_ps_file(pdf_file)
      system "open #{pdf_file}.pdf" if config["open_pdf"]
    end
  end
end