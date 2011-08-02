# encoding: UTF-8
require File.dirname(__FILE__) + '/helper'
File.delete(File.dirname(__FILE__) + '/views/layout.test') rescue nil

class TestTemplate < Tilt::Template
  def prepare
  end

  def evaluate(scope, locals={}, &block)
    inner = block ? block.call : ''
    data + inner
  end

  Tilt.register 'test', self
end

class TemplatesTest < Test::Unit::TestCase
  def render_app(base=Sinatra::Base, options = {}, &block)
    base, options = Sinatra::Base, base if base.is_a? Hash
    mock_app(base) {
      set :views, File.dirname(__FILE__) + '/views'
      set options
      get '/', &block
      template(:layout3) { "Layout 3!\n" }
    }
    get '/'
  end

  def with_default_layout
    layout = File.dirname(__FILE__) + '/views/layout.test'
    File.open(layout, 'wb') { |io| io.write "Layout!\n" }
    yield
  ensure
    File.unlink(layout) rescue nil
  end

  it 'renders String templates directly' do
    render_app { render :test, 'Hello World' }
    assert ok?
    assert_equal 'Hello World', body
  end

  it 'renders Proc templates using the call result' do
    render_app { render :test, Proc.new {'Hello World'} }
    assert ok?
    assert_equal 'Hello World', body
  end

  it 'looks up Symbol templates in views directory' do
    render_app { render :test, :hello }
    assert ok?
    assert_equal "Hello World!\n", body
  end

  it 'uses the default layout template if not explicitly overridden' do
    with_default_layout do
      render_app { render :test, :hello }
      assert ok?
      assert_equal "Layout!\nHello World!\n", body
    end
  end

  it 'uses the default layout template if not really overriden' do
    with_default_layout do
      render_app { render :test, :hello, :layout => true }
      assert ok?
      assert_equal "Layout!\nHello World!\n", body
    end
  end

  it 'uses the layout template specified' do
    render_app { render :test, :hello, :layout => :layout2 }
    assert ok?
    assert_equal "Layout 2!\nHello World!\n", body
  end

  it 'uses layout templates defined with the #template method' do
    render_app { render :test, :hello, :layout => :layout3 }
    assert ok?
    assert_equal "Layout 3!\nHello World!\n", body
  end

  it 'avoids wrapping layouts around nested templates' do
    render_app { render :str, :nested, :layout => :layout2 }
    assert ok?
    assert_equal "<h1>String Layout!</h1>\n<content><h1>Hello From String</h1></content>", body
  end

  it 'allows explicitly wrapping layouts around nested templates' do
    render_app { render :str, :explicitly_nested, :layout => :layout2 }
    assert ok?
    assert_equal "<h1>String Layout!</h1>\n<content><h1>String Layout!</h1>\n<h1>Hello From String</h1></content>", body
  end

  it 'two independent render calls do not disable layouts' do
    render_app do
      render :str, :explicitly_nested, :layout => :layout2
      render :str, :nested, :layout => :layout2
    end
    assert ok?
    assert_equal "<h1>String Layout!</h1>\n<content><h1>Hello From String</h1></content>", body
  end

  it 'is possible to use partials in layouts' do
    render_app do
      settings.layout { "<%= erb 'foo' %><%= yield %>" }
      erb 'bar'
    end
    assert ok?
    assert_equal "foobar", body
  end

  it 'loads templates from source file' do
    mock_app { enable :inline_templates }
    assert_equal "this is foo\n\n", @app.templates[:foo][0]
    assert_equal "X\n= yield\nX\n", @app.templates[:layout][0]
  end

  it 'ignores spaces after names of inline templates' do
    mock_app { enable :inline_templates }
    assert_equal "There's a space after 'bar'!\n\n", @app.templates[:bar][0]
    assert_equal "this is not foo\n\n", @app.templates[:"foo bar"][0]
  end

  it 'loads templates from given source file' do
    mock_app { set :inline_templates, __FILE__ }
    assert_equal "this is foo\n\n", @app.templates[:foo][0]
  end

  test 'inline_templates ignores IO errors' do
    assert_nothing_raised {
      mock_app {
        set :inline_templates, '/foo/bar'
      }
    }

    assert @app.templates.empty?
  end

  it 'allows unicode in inline templates' do
    mock_app { set :inline_templates, __FILE__ }
    assert_equal "Den som tror at hemma det är där man bor har aldrig vart hos mig.\n\n",
      @app.templates[:umlaut][0]
  end

  it 'loads templates from specified views directory' do
    render_app { render :test, :hello, :views => options.views + '/foo' }

    assert_equal "from another views directory\n", body
  end

  it 'passes locals to the layout' do
    mock_app {
      template :my_layout do
        'Hello <%= name %>!<%= yield %>'
      end

      get '/' do
        erb '<p>content</p>', { :layout => :my_layout }, { :name => 'Mike'}
      end
    }

    get '/'
    assert ok?
    assert_equal 'Hello Mike!<p>content</p>', body
  end

  it 'loads templates defined in subclasses' do
    base = Class.new(Sinatra::Base)
    base.template(:foo) { 'bar' }
    render_app(base) { render :test, :foo }
    assert ok?
    assert_equal 'bar', body
  end

  it 'allows setting default content type per template engine' do
    render_app(:str => { :content_type => :txt }) { render :str, 'foo' }
    assert_equal 'text/plain;charset=utf-8', response['Content-Type']
  end

  it 'setting default content type does not affect other template engines' do
    render_app(:str => { :content_type => :txt }) { render :test, 'foo' }
    assert_equal 'text/html;charset=utf-8', response['Content-Type']
  end

  it 'setting default content type per template engine does not override content_type' do
    render_app :str => { :content_type => :txt } do
      content_type :html
      render :str, 'foo'
    end
    assert_equal 'text/html;charset=utf-8', response['Content-Type']
  end

  it 'uses templates in superclasses before subclasses' do
    base = Class.new(Sinatra::Base)
    base.template(:foo) { 'template in superclass' }
    assert_equal 'template in superclass', base.templates[:foo].first.call

    mock_app(base) {
      set :views, File.dirname(__FILE__) + '/views'
      template(:foo) { 'template in subclass' }
      get('/') { render :test, :foo }
    }
    assert_equal 'template in subclass', @app.templates[:foo].first.call

    get '/'
    assert ok?
    assert_equal 'template in subclass', body
  end

  it "is possible to use a different engine for the layout than for the template itself explicitely" do
    render_app do
      settings.template(:layout) { 'Hello <%= yield %>!' }
      render :str, "<%= 'World' %>", :layout_engine => :erb
    end
    assert_equal "Hello <%= 'World' %>!", body
  end

  it "is possible to use a different engine for the layout than for the template itself globally" do
    render_app :str => { :layout_engine => :erb } do
      settings.template(:layout) { 'Hello <%= yield %>!' }
      render :str, "<%= 'World' %>"
    end
    assert_equal "Hello <%= 'World' %>!", body
  end

  it "does not leak the content type to the template" do
    render_app :str => { :layout_engine => :erb } do
      settings.template(:layout) { 'Hello <%= yield %>!' }
      render :str, "<%= 'World' %>", :content_type => :txt
    end
    assert_equal "text/html;charset=utf-8", headers['Content-Type']
  end

  it "is possible to register another template" do
    Tilt.register "html.erb", Tilt[:erb]
    render_app { render :erb, :calc }
    assert_equal '2', body
  end

  it "passes scope to the template" do
    mock_app do
      template :scoped do
        'Hello <%= foo %>'
      end

      get '/' do
        some_scope = Object.new
        def some_scope.foo() 'World!' end
        erb :scoped, :scope => some_scope
      end
    end

    get '/'
    assert ok?
    assert_equal 'Hello World!', body
  end

  it "is possible to use custom logic for finding template files" do
    mock_app do
      set :views, ["a", "b"].map { |d| File.dirname(__FILE__) + '/views/' + d }
      def find_template(views, name, engine, &block)
        Array(views).each { |v| super(v, name, engine, &block) }
      end

      get('/:name') do
        render :str, params[:name].to_sym
      end
    end

    get '/in_a'
    assert_body 'Gimme an A!'

    get '/in_b'
    assert_body 'Gimme a B!'
  end
end

# __END__ : this is not the real end of the script.

__END__

@@ foo
this is foo

@@ bar 
There's a space after 'bar'!

@@ foo bar
this is not foo

@@ umlaut
Den som tror at hemma det är där man bor har aldrig vart hos mig.

@@ layout
X
= yield
X
