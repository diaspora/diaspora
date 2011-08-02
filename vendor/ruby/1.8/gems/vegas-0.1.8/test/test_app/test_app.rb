require 'rubygems'
require 'sinatra'

class TestApp < Sinatra::Base
  
  get '/' do
    'This is a TEST: params: ' + params.inspect
  end
  
end