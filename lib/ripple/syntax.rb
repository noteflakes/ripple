module Ripple
  module Syntax
    ACCIDENTAL = {'s' => 'is', 'b' => 'es', 'ss' => 'isis', 'bb' => 'eses'}
    ACCIDENTAL_RE = /\b([a-g])([sb]{1,2})([^a-z])?/
    
    VALUE_RE = /\b([ra-g])([^\s]+)?([36])([^\d\w])?/
    VALUE = {'3' => '32', '6' => '16'}
    
    APPOGGIATURE_RE = /(\s)?\^([a-g])/

    BEAM_RE = /([^\s\[\(]*)\[(\s?[^\s\^\\]*)/
    SLUR_RE = /([^\s\[\(]*)\((\s?[^\s\^\\]*)/

    # BEAM_RE = /([^\s\[\(]*)\[(\s?[^\s]*)/
    # SLUR_RE = /([^\s\(\(]*)\((\s?[^\s]*)/
    BEAM_SLUR_INNER_RE = /([^\s]+)(.*)/
    
    PART_ONLY_RE = /\[\[((?:(?:\](?!\]))|[^\]])+)\]\]/m
    SCORE_ONLY_RE = /\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    MIDI_ONLY_RE = /m\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    
    DIVISE_RE = /\/1\s([^\/]+)\/2\s([^\/]+)\/u\s/
    
    def convert_prefixed_beams_and_slurs(m)
      m.gsub(BEAM_RE) do |i| 
        pre, post = $1, $2
        (pre.empty? && post =~ BEAM_SLUR_INNER_RE) ?
          "#{$1}[#{$2}" : i
      end.gsub(SLUR_RE) do |i| 
        pre, post = $1, $2
        (pre.empty? && post =~ BEAM_SLUR_INNER_RE) ?
          "#{$1}(#{$2}" : i
      end
    end
    
    INLINE_INCLUDE_RE = /\\inlineInclude\s(\S+)/
    
    def convert_inline_includes(m, fn, mode)
      m.gsub(INLINE_INCLUDE_RE) do |i|
        include_fn = File.join(File.dirname(fn), $1)
        load_music(include_fn, mode)
      end
    end
    
    MACRO_GOBBLE_RE = /([a-gr](?:[bs]?)(?:[,'!?]+)?)([\\\^_]\S+)?/
    MACRO_REPLACE_RE = /([#\@])([^\s\)]+)?/

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
      if rpl_mode
        m = m.gsub(MIDI_ONLY_RE) {(mode == :midi) ? $1 : ''}.
          gsub(PART_ONLY_RE) {(mode == :part) ? $1 : ''}.
          gsub(SCORE_ONLY_RE) {(mode == :score) ? $1 : ''}

        m = convert_macros(m, config)
        
        m = convert_prefixed_beams_and_slurs(m).
          gsub(DIVISE_RE) {"<< { \\voiceOne #{$1}} \\new Voice { \\voiceTwo #{$2}} >> \\oneVoice "}.
          gsub(ACCIDENTAL_RE) {"#{$1}#{ACCIDENTAL[$2]}#{$3}"}.
          gsub(VALUE_RE) {"#{$1}#{$2}#{VALUE[$3]}#{$4}"}.
          gsub(APPOGGIATURE_RE) {"#{$1}\\appoggiatura #{$2}"}
      end
      
      convert_inline_includes(m, fn, mode)
    end
    
    def load_music(fn, mode, config)
      rpl_mode = fn =~ /\.rpl$/
      convert_syntax(IO.read(fn), fn, rpl_mode, mode, config)
    end
  end
end