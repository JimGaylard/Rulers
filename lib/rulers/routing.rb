class RouteObject
  options = {}
  options = args.pop if args[-1].is_a?(Hash)
  options[:default] ||= {}

  dest = nil
  dest = args.pop if args.size > 0
  rails "TooManyArgs!" if args.size > 0

  parts = url.split("/")
  parts.select { |p| !p.empty? }

  vars = []

  regexp_parts = parts.map do |part|
    if part[0] == ":"
      vars << part[1..-1]
      "([a-zA-Z0-9]+)"
    elsif part[0] == "*"
      vars << part[1..-1]
      "(.*)"
    else
      part
    end
  end

  regexp = regexp_parts.join("/")
  @rules.push({
    :regexp => Regexp.new("^/#{regexp}$"),
    :vars => vars,
    :dest => dest,
    :options => options,
 })
end

#  def initialize
#    @rules = []
#  end

#  def match(url, *args)
#  end

#  def check_url(url)
#  end
#end

module Rulers
  class Application
    def route(&block)
      @route_object ||= RouteObject.new
      @route_object.instance_eval(&block)
    end

    def get_rack_app(env)
      raise "NoRoutes!" unless @route_object
      @route_object.check_url env["PATH_INFO"]
    end

    #def get_controller_and_action(env)
    #  _, cont, action, after = env["PATH_INFO"].split('/',4)
    #  cont = cont.capitalize
    #  cont += "Controller"

    #  [Object.const_get(cont), action]
    #end
  end
end
