require 'json'
require 'webrick'

class Session
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app'
        @session = JSON.parse(cookie.value)
      end
    end
    
    @session ||= {}
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  def store_session(res)
    cookie_val = @session
    cookie = WEBrick::Cookie.new('_rails_lite_app', cookie_val.to_json)
    res.cookies << cookie
  end
end
