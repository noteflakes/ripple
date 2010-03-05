class Fixnum
  ROMAN = %w[0 I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX
    XX XXI XXII XXIII XXIV XXV XXVI XXVII XXVIII XXIX XXX]
  
  def to_roman
    ROMAN[self]
  end
end

class String
  def titlize(all_capitals = false)
    all_capitals ? 
      self.gsub("-", " ").gsub(/\b('?[a-z])/) {$1.capitalize} :
      self.gsub("-", " ").capitalize
  end
  
  def to_movement_title
    case self
    when /^\-\d+\-(.+)$/
      $1.titlize(true)
    when /^(\d+)\-(.+)$/
      "#{$1.to_i}. #{$2.titlize(true)}"
    when /^(\d+)$/
      num = $1.to_i.to_roman
    else
      self
    end
  end
  
  def to_instrument_title
    if self =~ /^([^\d]+)(\d+)$/
      "#{$1.titlize} #{$2.to_i.to_roman}"
    else
      self.titlize
    end
  end
  
  # Works like inspect, except it unescapes Unicode sequences
  def ly_inspect
    inspect.gsub(/(\\(\d{3}))/) {[$2.oct].pack("c")}
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

    target.deep = true
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
  
  attr_accessor :deep

  alias_method :old_get, :[]
  def [](k)
    if @deep && k.is_a?(String) && k =~ /\//
      lookup(k)
    else
      old_get(k)
    end
  end
  
  alias_method :old_set, :[]=
  def []=(k, v)
    if @deep && k.is_a?(String) && k =~ /\//
      set(k, v)
    else
      old_set(k, v)
    end
  end
  
  alias_method :old_merge, :merge
  def merge(hash)
    if deep || hash.deep
      deep_merge(hash)
    else
      old_merge(hash)
    end
  end
end

class Array
  # Returns the index of an array of items inside the array:
  # 
  #   [1,2,3,4,5].array_index([3,4]) #=> 2
  #   [1,2,3,4,5].array_index([3,5]) #=> nil
  def array_index(arr)
    f = arr[0]
    return nil unless idx = index(f)
    return idx if self[idx, arr.size] == arr
  end
end