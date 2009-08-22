module Ripple
  module Syntax
    ACCIDENTAL = {'s' => 'is', 'b' => 'es', 'ss' => 'isis', 'bb' => 'eses'}
    ACCIDENTAL_RE = /\b([a-g])([sb]{1,2})([^a-z])?/
    
    VALUE_RE = /\b([ra-g])([^\s]+)?([36])([^\d\w])?/
    VALUE = {'3' => '32', '6' => '16'}
    
    APPOGGIATURE_RE = /(\s)?\^([a-g])/

    BEAM_RE = /([^\s\[\(]*)\[(\s?[^\s]*)/
    SLUR_RE = /([^\s\(\(]*)\((\s?[^\s]*)/
    BEAM_SLUR_INNER_RE = /([^\s]+)(.*)/
    
    PART_ONLY_RE = /\\partOnly\s*\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    SCORE_ONLY_RE = /\\scoreOnly\s*\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    MIDI_ONLY_RE = /\\midiOnly\s*\{\{((?:(?:\}(?!\}))|[^\}])+)\}\}/m
    
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
    
    def convert_rpl(m, mode = nil)
      convert_prefixed_beams_and_slurs(m).
        gsub(ACCIDENTAL_RE) {"#{$1}#{ACCIDENTAL[$2]}#{$3}"}.
        gsub(VALUE_RE) {"#{$1}#{$2}#{VALUE[$3]}#{$4}"}.
        gsub(APPOGGIATURE_RE) {"#{$1}\\appoggiatura #{$2}"}.

        gsub(PART_ONLY_RE) {(mode == :part) ? $1 : ''}.
        gsub(SCORE_ONLY_RE) {(mode == :score) ? $1 : ''}.
        gsub(MIDI_ONLY_RE) {(mode == :midi) ? $1 : ''}
    end
    
    def load_music(fn, mode = nil)
      m = IO.read(fn)
      fn =~ /\.rpl$/ ? convert_rpl(m, mode) : m
    end
  end
end