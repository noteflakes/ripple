module Ripple
  module LyricsSyntax
    LYRICS_RE = /([^\\-_])(?:([\-]+)|([_]+))/
    ESCAPE_RE = /\\(_|\-)/

    def convert_lyrics(lyrics, fn, mode, config)
      lyrics.gsub(LYRICS_RE) do
        if $2
          "#{$1} -- #{"_ " * ($2.size - 1)}"
        elsif $3
          "#{$1} __ #{"_ " * ($3.size - 1)}"
        end
      end.gsub(ESCAPE_RE) {$1}
    end
    
    def load_lyrics(fn, mode, config)
      rpl_mode = fn =~ /\.lyr(\d*)$/
      lyrics = IO.read(fn)
      rpl_mode ? convert_lyrics(lyrics, fn, mode, config) : lyrics
    end
    

    class Proxy
      class << self
        include Ripple::LyricsSyntax
      
        def cvt(lyrics, mode = nil, config = {})
          convert_lyrics(lyrics, '', mode, config)
        end
      end
    end
    
    def self.cvt(lyrics, mode = nil, config = {})
      Proxy.cvt(lyrics, mode, config)
    end
  end
end
