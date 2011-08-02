class TestApp1 < Sinatra::Base
  
  get '/' do
    'TestApp1 Index'
  end
  
  get '/route' do
    'TestApp1 route'
  end
end


class TestApp2 < Sinatra::Base
  
  get '/' do
    'TestApp2 Index'
  end
  
  get '/route' do
    'TestApp2 route'
  end
end

RackApp1 = Proc.new {|env| 
  [200, {'Content-Type' => 'text/plain'}, ["This is an app. #{env.inspect}"]]
}