require "erubis"
require "rulers/file_model"
require "rack/request"

module Rulers
  class Controller
    include Rulers::Model

    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def env
      @env
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    # sends the action to the controller and
    # returns Rack response
    def dispatch(action, routing_params = {})
      @routing_params  = routing_params
      text = self.send(action)
      if get_response
        status, headers, text  = get_response.to_a
        [status, headers, [text].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    # wraps the controller/action in a proc for Rack
    def self.action(act, rp = {})
      proc { |env| self.new(env).dispatch(act, rp) }
    end

    def params
      request.params.merge @routing_params
    end

    # checks if already responded and raises error
    # returns @response - Rack::Response to 
    def response(text, status = 200, headers = {})
      raise "Already responded!" if @response
      a = [text].flatten
      @response = Rack::Response.new(a, status, headers)
    end

    def get_response
      @response
    end

    # called by controller instances
    # calls response on erubis result
    def render_response(*args)
      response(render(*args))
    end

    # renders view name and passes in local variables
    # to erubis
    # returns erubis result
    def render(view_name, locals = {})
      filename = File.join "app", "views",
        controller_name, "#{view_name}.html.erb"
      template = File.read filename
      eruby = Erubis::Eruby.new(template)
      eruby.result locals.merge(:env => env)
    end

    def controller_name
      klass = self.class
      klass = klass.to_s.gsub(/Controller$/, "")
      Rulers.to_underscore(klass)
    end
  end
end
