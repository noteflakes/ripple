module Ripple
  module Syntax
    SKIP_QUOTES_RE = /([^"]+)("[^"]+")?/m
    
    ACCIDENTAL = {'s' => 'is', 'b' => 'es', 'ss' => 'isis', 'bb' => 'eses'}
    ACCIDENTAL_RE = /\b([a-g])([sb]{1,2})([^a-z])?/
    
    VALUE_RE = /([a-gr](?:[bs]+)?(?:[',]+)?(?:[!\?])?)([36]4?)/
    VALUE = {'3' => '32', '6' => '16', '64' => '64'}
    
    APPOGGIATURE_RE = /(\s)?\^([a-g])/

    PART_ONLY_RE = /\[\[((?:(?:\](?!\]))|[^\]])+)\]\]/m
    SCORE_ONLY_RE = /\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    MIDI_ONLY_RE = /m\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    
    DIVISI_RE = /\/1\s([^\/]+)\/2\s([^\/]+)\/u\s/
    
    BEAM_SLUR_RE = /([\[\(]+)([a-g](?:[bs]+)?(?:[',]+)?(?:[!\?])?([\d*\/]+)?\.?)/m
    
    def convert_prefixed_beams_and_slurs(m)
      m.gsub(BEAM_SLUR_RE) {"#{$2}#{$1}"}
    end
    
    INLINE_INCLUDE_RE = /\\inlineInclude\s(\S+)/
    
    def convert_inline_includes(m, fn, mode)
      m.gsub(INLINE_INCLUDE_RE) do |i|
        include_fn = File.join(File.dirname(fn), $1)
        load_music(include_fn, mode)
      end
    end
    
    MACRO_GOBBLE_RE = /([a-gr](?:[bs]?)(?:[,'!?]+)?)([\\\^_]\S+)?/
    MACRO_REPLACE_RE = /([#\@])([^\s]+)?/

    def convert_macro_region(pattern, m)
      size = pattern.count('#')
      accum = []; buffer = ''; last_note = nil
      m.gsub(MACRO_GOBBLE_RE) do |i|
        accum << [$1, $2]
        if accum.size == size
          buffer << pattern.gsub(MACRO_REPLACE_RE) do |i|
            note = ($1 == '@') ? last_note : accum.shift
            last_note = note
            "#{note[0]}#{$2}#{note[1]}"
          end
          buffer << " "
          accum = []
        end
      end
      buffer
    end
    
    INLINE_MACRO_RE = /\$\!([^\$]+)\$(?::([a-z0-9\._]+))?([^\$]+)(?:\$\$)?/m
    NAMED_MACRO_RE = /\$(?:([a-z0-9\._]+)\s)([^\$]+)(?:\$\$)?/m
    
    def convert_macros(m, config)
      m.gsub(INLINE_MACRO_RE) {
        config.set("macros/#{$2}", $1) if $2
        convert_macro_region($1, $3)
      }.gsub(NAMED_MACRO_RE) { |i|
        convert_macro_region(config.lookup("macros/#{$1}"), $2)
      }
    end
    
    def convert_syntax(m, fn, rpl_mode, mode, config)
      m = m.gsub(MIDI_ONLY_RE) {(mode == :midi) ? $1 : ''}.
        gsub(PART_ONLY_RE) {(mode == :part) ? $1 : ''}.
        gsub(SCORE_ONLY_RE) {(mode == :score) ? $1 : ''}

      if rpl_mode
        m = m.gsub(SKIP_QUOTES_RE) do
          a,q = convert_macros($1, config), $2
          a = convert_prefixed_beams_and_slurs(a).
            gsub(DIVISI_RE) {"<< { \\voiceOne #{$1}} \\new Voice { \\voiceTwo #{$2}} >> \\oneVoice "}.
            # gsub(VALUE_RE) {"#{$1}#{$2}#{VALUE[$3]}#{$4}"}.
            gsub(VALUE_RE) {"#{$1}#{VALUE[$2]}"}.
            gsub(ACCIDENTAL_RE) {"#{$1}#{ACCIDENTAL[$2]}#{$3}"}.
            gsub(APPOGGIATURE_RE) {"#{$1}\\appoggiatura #{$2}"}
          "#{a}#{q}"
        end
      end
      
      convert_inline_includes(m, fn, mode)
    end
    
    def load_music(fn, mode, config)
      rpl_mode = fn =~ /\.rpl$/
      convert_syntax(IO.read(fn), fn, rpl_mode, mode, config)
    end
    
    class Proxy
      class << self
        include Ripple::Syntax
      
        def cvt(m, mode = nil, config = {})
          convert_syntax(m, '', true, mode, config)
        end
      end
    end
    
    def self.cvt(m, mode = nil, config = {})
      Proxy.cvt(m, mode, config)
    end
  end
end