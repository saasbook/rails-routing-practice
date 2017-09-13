require 'sinatra/base'
require './lib/route_recognizer.rb'
require 'byebug'

Result = Struct.new(:route, :controller, :action, :params, :error)

class RouteRecognizerApp < Sinatra::Base

  get '/' do
    @router = RouteRecognizer.new('')
    @result = nil
    erb :main
  end

  post '/' do
    @router = RouteRecognizer.new(params[:routes_table_text])
    @result = Result.new
    @result.route = "#{params[:route_method].upcase} #{params[:route_uri]}"
    result_params = @router.recognize(params[:route_method], params[:route_uri])
    if result_params
      @result.controller = result_params.delete(:controller)
      @result.action = result_params.delete(:action)
      @result.params = result_params
    else
      @result.error = "doesn't match any of the route patterns above."
    end
    erb :main
  end
end
