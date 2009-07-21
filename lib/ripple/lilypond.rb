module Ripple
  module Lilypond
    def self.delete_ps_file(pdf_file)
      FileUtils.rm("#{pdf_file}.ps") rescue nil
    end
    
    def self.process(ly_file, pdf_file)
      system "ly --pdf -o \"#{pdf_file}\" \"#{ly_file}\""
      delete_ps_file(pdf_file)
    end
  end
end