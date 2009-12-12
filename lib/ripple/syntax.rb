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
    
    def convert_syntax(m, fn, rpl_mode, mode)
      if rpl_mode
        m = m.gsub(MIDI_ONLY_RE) {(mode == :midi) ? $1 : ''}.
          gsub(PART_ONLY_RE) {(mode == :part) ? $1 : ''}.
          gsub(SCORE_ONLY_RE) {(mode == :score) ? $1 : ''}

        m = convert_prefixed_beams_and_slurs(m).
          gsub(ACCIDENTAL_RE) {"#{$1}#{ACCIDENTAL[$2]}#{$3}"}.
          gsub(VALUE_RE) {"#{$1}#{$2}#{VALUE[$3]}#{$4}"}.
          gsub(APPOGGIATURE_RE) {"#{$1}\\appoggiatura #{$2}"}
      end
      
      convert_inline_includes(m, fn, mode)
    end
    
    def load_music(fn, mode)
      rpl_mode = fn =~ /\.rpl$/
      convert_syntax(IO.read(fn), fn, rpl_mode, mode)
    end
  end
end