require 'uri'

class Params
  def initialize(req, route_params)
    @req, @route_params = req, route_params
    @params = {}
    if req.query_string
      parse_www_encoded_form(req.query_string)
    elsif req.body
      parse_www_encoded_form(req.body)
    end
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    params_array = URI.decode_www_form(www_encoded_form)
  
    params_array.each do |sub_array|
      hash_level = @params
      
      keys = sub_array.first
      value = sub_array.last
      keys_array = parse_key(keys)
 
      keys_array.each do |key_level|
        if key_level == keys_array.last
          hash_level[key_level] = value
        else
          hash_level[key_level] = {} if hash_level[key_level] == nil
          hash_level = hash_level[key_level]
        end
      end
    end
    
    @params
  end

  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
