require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    
    if (req.query_string || req.body)
      @params = Params.new(req, route_params).to_s 
    end
  end

  def session
   @session ||= Session.new(@req)
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    @res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, url)

    session.store_session(@res)
    @response_built = true    
  end

  def render_content(content, type)
    @res.body = content
    @res.content_type = type
    
    session.store_session(@res)
    @already_rendered = true
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    file_name = "views/#{controller_name}/#{template_name}.html.erb"
    template = ERB.new(File.read(file_name))
    
    render_content(template.result(binding), 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
