require 'erb'
require_relative 'params'
require_relative 'session'
require_relative 'flash'
require 'active_support/core_ext'
require_relative 'helpers'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    
    @flash = Flash.new(req)
    @params = Params.new(req, route_params) 
    @already_rendered = false
  end

  def session
   @session ||= Session.new(@req)
  end
  
  def flash
    @flash 
  end

  def already_rendered?
    @already_rendered
  end

  def redirect_to(url)
    @res.status = 302
    @res.header["location"] = url
    
    session.store_session(@res)
    flash.store_flash(@res)
    
    @already_rendered = true    
  end

  def render_content(content, type)
    @res.body = content
    @res.content_type = type
    
    session.store_session(@res)
    flash.store_flash(@res)
    
    @already_rendered = true
  end

  def render(template_name)
    controller_name = self.class.underscore
    
    file_name = "views/#{controller_name}/#{template_name}.html.erb"
    template = ERB.new(File.read(file_name))
    
    render_content(template.result(binding), 'text/html')
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end