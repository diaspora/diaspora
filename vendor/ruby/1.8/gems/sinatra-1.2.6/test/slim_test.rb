require File.dirname(__FILE__) + '/helper'

begin
require 'slim'

class SlimTest < Test::Unit::TestCase
  def slim_app(&block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    }
    get '/'
  end

  it 'renders inline slim strings' do
    slim_app { slim "h1 Hiya\n" }
    assert ok?
    assert_equal "<h1>Hiya</h1>", body
  end
  
  it 'renders .slim files in views path' do
    slim_app { slim :hello }
    assert ok?
    assert_equal "<h1>Hello From Slim</h1>", body
  end
  
  it "renders with inline layouts" do
    mock_app {
      layout { %(h1\n  | THIS. IS. \n  == yield.upcase ) }
      get('/') { slim 'em Sparta' }
    }
    get '/'
    assert ok?
    assert_equal "<h1>THIS. IS. <EM>SPARTA</EM></h1>", body
  end
  
  it "renders with file layouts" do
    slim_app {
      slim '| Hello World', :layout => :layout2
    }
    assert ok?
    assert_equal "<h1>Slim Layout!</h1><p>Hello World</p>", body
  end
  
  it "raises error if template not found" do
    mock_app {
      get('/') { slim :no_such_template }
    }
    assert_raise(Errno::ENOENT) { get('/') }
  end
  
  HTML4_DOCTYPE = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"
  
  it "passes slim options to the slim engine" do
    mock_app {
      get '/' do
        slim "! doctype html\nh1 Hello World", :format => :html4
      end
    }
    get '/'
    assert ok?
    assert_equal "#{HTML4_DOCTYPE}<h1>Hello World</h1>", body
  end
  
  it "passes default slim options to the slim engine" do
    mock_app {
      set :slim, {:format => :html4}
      get '/' do
        slim "! doctype html\nh1 Hello World"
      end
    }
    get '/'
    assert ok?
    assert_equal "#{HTML4_DOCTYPE}<h1>Hello World</h1>", body
  end
  
  it "merges the default slim options with the overrides and passes them to the slim engine" do
    mock_app {
      set :slim, {:format => :html4}
      get '/' do
        slim "! doctype html\nh1.header Hello World"
      end
      get '/html5' do
        slim "! doctype html\nh1.header Hello World", :format => :html5
      end
    }
    get '/'
    assert ok?
    assert_match(/^#{HTML4_DOCTYPE}/, body)
    get '/html5'
    assert ok?
    assert_equal "<!DOCTYPE html><h1 class=\"header\">Hello World</h1>", body
  end
end

rescue LoadError
  warn "#{$!.to_s}: skipping slim tests"
end
