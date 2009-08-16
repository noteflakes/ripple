class String
  def to_movement_title
    if self =~ /^(\d+)\-(.+)$/
      num = $1.to_i
      name = $2.gsub("-", " ").gsub(/\b('?[a-z])/) {$1.capitalize}
      "#{num}. #{name}"
    else
      self
    end
  end
  
  ROMAN = %w[0 I II III IV V VI VII VIII IX X]
  
  def to_instrument_title
    if self =~ /^([^\d]+)(\d+)$/
      "#{$1.capitalize} #{ROMAN[$2.to_i]}"
    else
      self.capitalize
    end
  end
  
  def to_title
    gsub(/\b('?[a-z])/) {$1.capitalize}
  end
end

class Hash
  # Merges self with another hash, recursively.
  #
  # This code was lovingly stolen from some random gem:
  # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
  #
  # Thanks to whoever made it.
  def deep_merge(hash)
    target = dup

    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end

      target[key] = hash[key]
    end

    target
  end

  def lookup(path)
    path.split("/").inject(self) {|m,i| m[i].nil? ? (return nil) : m[i]}
  end
  
  def set(path, value)
    leafs = path.split("/")
    k = leafs.pop
    h = leafs.inject(self) {|m, i| m[i].is_a?(Hash) ? m[i] : (m[i] = {})}
    h[k] = value
  end
end
