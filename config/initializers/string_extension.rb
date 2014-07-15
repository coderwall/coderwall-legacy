String.class_eval do
  def to_hex
    Digest::MD5.hexdigest("z#{self}").to_s[0..5].upcase
  end
end
