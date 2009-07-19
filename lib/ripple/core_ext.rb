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
  
  def to_title
    gsub(/\b('?[a-z])/) {$1.capitalize}
  end
end

