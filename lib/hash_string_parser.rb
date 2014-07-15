require 'json'

class HashStringParser
  def self.better_than_eval(hash_string_to_parse)
    # This code is bad and I should feel bad.
    JSON.parse('{' + hash_string_to_parse.gsub(/^{|}$/, '').split(', ').
               map { |pair| pair.split('=>') }.
               map { |k, v| [k.gsub(/^:(\w*)/, '"\1"'), v == 'nil' ? 'null' : v].join(': ') }.join(', ') + '}')
  end
end
