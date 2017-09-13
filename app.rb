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
    byebug
    @router = RouteRecognizer.new(params[:routes_table_text])
    result_params = @router.recognize(params[:route_method], params[:route_uri])
    @result = Result.new
    @result.route = "#{params[:route_method].upcase} #{params[:route_uri]}"
    @result.controller = result_params.delete(:controller)
    @result.action = result_params.delete(:action)
    @result.params = result_params
    erb :main
  end
end
