class Flash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_flash'
        @old_flash = JSON.parse(cookie.value)
        cookie.expires = Time.now
      end
    end
    
    @old_flash ||= {}
    @new_flash = {}
  end 
  
  def [](key)
    @old_flash[key]
  end

  def []=(key, val)
    @new_flash[key] = val
  end
  
  def increment(key, val)
    @new_flash[key] = val + @old_flash[key]
  end

  def store_flash(res)
    cookie_val = @new_flash
    cookie_val["authenticity_token"] = SecureRandom::urlsafe_base64
    
    cookie = WEBrick::Cookie.new('_rails_lite_flash', cookie_val.to_json)
    res.cookies << cookie
  end
end

