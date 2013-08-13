class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name = 
      pattern, http_method, controller_class, action_name
  end

  def matches?(req)
    req_sym = req.request_method.downcase.to_sym
    
    (pattern =~ req.path) && (req_sym == http_method)
  end

  def run(req, res)
    @controller_class.new(req, res).invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|    
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end
    
    nil
  end

  def run(req, res)
    route = match(req)
    route ? route.run(req, res) : (res.status = '404')
  end
end
