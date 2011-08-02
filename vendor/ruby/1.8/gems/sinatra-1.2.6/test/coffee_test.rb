require File.dirname(__FILE__) + '/helper'

begin
require 'coffee-script'
require 'execjs'

begin
  ExecJS.compile '1'
rescue Exception
  raise LoadError, 'unable to execute JavaScript'
end

class CoffeeTest < Test::Unit::TestCase
  def coffee_app(options = {}, &block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'
      set(options)
      get '/', &block
    }
    get '/'
  end

  it 'renders inline Coffee strings' do
    coffee_app { coffee "alert 'Aye!'\n" }
    assert ok?
    assert body.include?("alert('Aye!');")
  end

  it 'defaults content type to javascript' do
    coffee_app { coffee "alert 'Aye!'\n" }
    assert ok?
    assert_equal "application/javascript;charset=utf-8", response['Content-Type']
  end

  it 'defaults allows setting content type per route' do
    coffee_app do
      content_type :html
      coffee "alert 'Aye!'\n"
    end
    assert ok?
    assert_equal "text/html;charset=utf-8", response['Content-Type']
  end

  it 'defaults allows setting content type globally' do
    coffee_app(:coffee => { :content_type => 'html' }) do
      coffee "alert 'Aye!'\n"
    end
    assert ok?
    assert_equal "text/html;charset=utf-8", response['Content-Type']
  end

  it 'renders .coffee files in views path' do
    coffee_app { coffee :hello }
    assert ok?
    assert_include body, "alert(\"Aye!\");"
  end

  it 'ignores the layout option' do
    coffee_app { coffee :hello, :layout => :layout2 }
    assert ok?
    assert_include body, "alert(\"Aye!\");"
  end

  it "raises error if template not found" do
    mock_app {
      get('/') { coffee :no_such_template }
    }
    assert_raise(Errno::ENOENT) { get('/') }
  end

  it "passes coffee options to the coffee engine" do
    coffee_app { coffee "alert 'Aye!'\n", :no_wrap => true }
    assert ok?
    assert_equal "alert('Aye!');", body
  end

  it "passes default coffee options to the coffee engine" do
    mock_app do
      set :coffee, :no_wrap => true # default coffee style is :nested
      get '/' do
        coffee "alert 'Aye!'\n"
      end
    end
    get '/'
    assert ok?
    assert_equal "alert('Aye!');", body
  end
end

rescue LoadError
  warn "#{$!.to_s}: skipping coffee tests"
end
