require File.dirname(__FILE__) + '/helper'

begin
require 'erubis'

class ERubisTest < Test::Unit::TestCase
  def erubis_app(&block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    }
    get '/'
  end

  it 'renders inline ERubis strings' do
    erubis_app { erubis '<%= 1 + 1 %>' }
    assert ok?
    assert_equal '2', body
  end

  it 'renders .erubis files in views path' do
    erubis_app { erubis :hello }
    assert ok?
    assert_equal "Hello World\n", body
  end

  it 'takes a :locals option' do
    erubis_app {
      locals = {:foo => 'Bar'}
      erubis '<%= foo %>', :locals => locals
    }
    assert ok?
    assert_equal 'Bar', body
  end

  it "renders with inline layouts" do
    mock_app {
      layout { 'THIS. IS. <%= yield.upcase %>!' }
      get('/') { erubis 'Sparta' }
    }
    get '/'
    assert ok?
    assert_equal 'THIS. IS. SPARTA!', body
  end

  it "renders with file layouts" do
    erubis_app {
      erubis 'Hello World', :layout => :layout2
    }
    assert ok?
    assert_equal "ERubis Layout!\nHello World\n", body
  end

  it "renders erubis with blocks" do
    mock_app {
      def container
        @_out_buf << "THIS."
        yield
        @_out_buf << "SPARTA!"
      end
      def is; "IS." end
      get '/' do
        erubis '<% container do %> <%= is %> <% end %>'
      end
    }
    get '/'
    assert ok?
    assert_equal 'THIS. IS. SPARTA!', body
  end

  it "can be used in a nested fashion for partials and whatnot" do
    mock_app {
      template(:inner) { "<inner><%= 'hi' %></inner>" }
      template(:outer) { "<outer><%= erubis :inner %></outer>" }
      get '/' do
        erubis :outer
      end
    }

    get '/'
    assert ok?
    assert_equal '<outer><inner>hi</inner></outer>', body
  end
end

rescue LoadError
  warn "#{$!.to_s}: skipping erubis tests"
end
