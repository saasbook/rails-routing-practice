require 'sinatra/base'
require './lib/route_recognizer.rb'

Result = Struct.new(:route, :controller, :action, :params, :error)

class RouteRecognizerApp < Sinatra::Base

  get '/' do
    @router = RouteRecognizer.new('')
    @result = nil
    erb :main
  end

  post '/' do
    @routes = params[:routes_table_text].to_s
    @result = Result.new
    method = params[:route_method].upcase
    @is_post = %w(POST PUT PATCH).include?(method)
    @result.route = "#{method} #{params[:route_uri]}"
    logger.info %Q{::#{@result.route}::#{@routes.gsub("\n"," ; ")}}
    begin
      @router = RouteRecognizer.new(@routes)
      result_params = @router.recognize(params[:route_method], params[:route_uri])
      @result.controller = result_params.delete(:controller)
      @result.action = result_params.delete(:action)
      @result.params = result_params
    rescue RouteRecognizer::NoMatchingRouteError => e
      @result.error = "doesn't match any of the route patterns above."
    rescue RouteRecognizer::InvalidRoutesError => e
      @result.error = "can't be parsed because your routes table (top of page) seems to contain an error: #{e.message}"
    end
    erb :main
  end
end
