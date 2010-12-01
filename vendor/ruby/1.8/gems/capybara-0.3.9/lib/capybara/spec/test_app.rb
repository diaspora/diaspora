require 'sinatra/base'
require 'rack'
require 'yaml'

class TestApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :static, true

  get '/' do
    'Hello world!'
  end

  get '/foo' do
    'Another World'
  end

  get '/redirect' do
    redirect '/redirect_again'
  end

  get '/redirect_again' do
    redirect '/landed'
  end

  get '/redirect/:times/times' do
    times = params[:times].to_i
    if times.zero?
      "redirection complete"
    else
      redirect "/redirect/#{times - 1}/times"
    end
  end

  get '/landed' do
    "You landed"
  end

  get '/with-quotes' do
    %q{"No," he said, "you can't do that."}
  end

  get '/form/get' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  get '/favicon.ico' do
    nil
  end

  post '/redirect' do
    redirect '/redirect_again'
  end

  delete "/delete" do
    "The requested object was deleted"
  end

  get '/redirect_back' do
    redirect back
  end

  get '/set_cookie' do
    cookie_value = 'test_cookie'
    response.set_cookie('capybara', cookie_value)
    "Cookie set to #{cookie_value}"
  end

  get '/get_cookie' do
    request.cookies['capybara']
  end

  get '/:view' do |view|
    erb view.to_sym
  end

  post '/form' do
    '<pre id="results">' + params[:form].to_yaml + '</pre>'
  end

  post '/upload' do
    begin
      buffer = []
      buffer << "Content-type: #{params[:form][:document][:type]}"
      buffer << "File content: #{params[:form][:document][:tempfile].read}"
      buffer.join(' | ')
    rescue
      'No file uploaded'
    end
  end
end

if __FILE__ == $0
  Rack::Handler::Mongrel.run TestApp, :Port => 8070
end
