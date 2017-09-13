class RouteRecognizer
  require 'rails'

  attr_accessor :router, :routes_as_string
  def initialize(string='')
    @routes_as_string = string
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw { eval string } unless string.blank?
  end

  def recognize(method,uri)
    rack_request = RackRequest.new(method,uri)
    request = ActionDispatch::Request.new(rack_request.env)
    all_params = nil
    @routes.router.recognize(request) do |route,params|
      all_params = request.query_parameters.merge params
    end
    return all_params
  end

  
  class RackRequest
    attr_accessor :method, :uri, :query_string, :path, :env
    def initialize(method,uri)
      @method,@uri = method,uri
      set_query_string!
      set_env!
    end
    
    private

    def set_env!
      @env = {
        'REQUEST_URI' => uri,
        'PATH_INFO' => path,
        'REQUEST_METHOD' => method
      }
      @env.merge!({'QUERY_STRING' => query_string}) if query_string
    end

    def set_query_string!
      if @uri =~ /(.+)\?(.+)\Z/
        @path,@query_string = $1,$2
      else                        # no query string
        @path = @uri
        @query_string = nil
      end
    end

  end
end
