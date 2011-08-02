require 'sinatra'

class App < Sinatra::Base
  get '/id/:id/wait/:wait' do |id, wait|
    sleep wait.to_i
    id.to_s
  end
end

run App
