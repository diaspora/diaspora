require File.dirname(__FILE__) + '/helper'

class SettingsTest < Test::Unit::TestCase
  setup do
    @base = Sinatra.new(Sinatra::Base)
    @base.set :environment, :foo

    @application = Sinatra.new(Sinatra::Application)
    @application.set :environment, :foo
  end

  it 'sets settings to literal values' do
    @base.set(:foo, 'bar')
    assert @base.respond_to?(:foo)
    assert_equal 'bar', @base.foo
  end

  it 'sets settings to Procs' do
    @base.set(:foo, Proc.new { 'baz' })
    assert @base.respond_to?(:foo)
    assert_equal 'baz', @base.foo
  end

  it 'sets settings using a block' do
    @base.set(:foo){ 'baz' }
    assert @base.respond_to?(:foo)
    assert_equal 'baz', @base.foo
  end

  it 'raises an error with a value and a block' do
    assert_raise ArgumentError do
      @base.set(:fiz, 'boom!'){ 'baz' }
    end
    assert !@base.respond_to?(:fiz)
  end

  it 'raises an error without value and block' do
    assert_raise(ArgumentError) { @base.set(:fiz) }
    assert !@base.respond_to?(:fiz)
  end

  it 'allows setting a value to the app class' do
    @base.set :base, @base
    assert @base.respond_to?(:base)
    assert_equal @base, @base.base
  end

  it 'raises an error with the app class as value and a block' do
    assert_raise ArgumentError do
      @base.set(:fiz, @base) { 'baz' }
    end
    assert !@base.respond_to?(:fiz)
  end

  it "sets multiple settings with a Hash" do
    @base.set :foo => 1234,
        :bar => 'Hello World',
        :baz => Proc.new { 'bizzle' }
    assert_equal 1234, @base.foo
    assert_equal 'Hello World', @base.bar
    assert_equal 'bizzle', @base.baz
  end

  it 'sets multiple settings using #each' do
    @base.set [["foo", "bar"]]
    assert_equal "bar", @base.foo
  end

  it 'inherits settings methods when subclassed' do
    @base.set :foo, 'bar'
    @base.set :biz, Proc.new { 'baz' }

    sub = Class.new(@base)
    assert sub.respond_to?(:foo)
    assert_equal 'bar', sub.foo
    assert sub.respond_to?(:biz)
    assert_equal 'baz', sub.biz
  end

  it 'overrides settings in subclass' do
    @base.set :foo, 'bar'
    @base.set :biz, Proc.new { 'baz' }
    sub = Class.new(@base)
    sub.set :foo, 'bling'
    assert_equal 'bling', sub.foo
    assert_equal 'bar', @base.foo
  end

  it 'creates setter methods when first defined' do
    @base.set :foo, 'bar'
    assert @base.respond_to?('foo=')
    @base.foo = 'biz'
    assert_equal 'biz', @base.foo
  end

  it 'creates predicate methods when first defined' do
    @base.set :foo, 'hello world'
    assert @base.respond_to?(:foo?)
    assert @base.foo?
    @base.set :foo, nil
    assert !@base.foo?
  end

  it 'uses existing setter methods if detected' do
    class << @base
      def foo
        @foo
      end
      def foo=(value)
        @foo = 'oops'
      end
    end

    @base.set :foo, 'bam'
    assert_equal 'oops', @base.foo
  end

  it "sets multiple settings to true with #enable" do
    @base.enable :sessions, :foo, :bar
    assert @base.sessions
    assert @base.foo
    assert @base.bar
  end

  it "sets multiple settings to false with #disable" do
    @base.disable :sessions, :foo, :bar
    assert !@base.sessions
    assert !@base.foo
    assert !@base.bar
  end

  it 'is accessible from instances via #settings' do
    assert_equal :foo, @base.new!.settings.environment
  end

  it 'is accessible from class via #settings' do
    assert_equal :foo, @base.settings.environment
  end

  describe 'methodoverride' do
    it 'is disabled on Base' do
      assert ! @base.method_override?
    end

    it 'is enabled on Application' do
      assert @application.method_override?
    end

    it 'enables MethodOverride middleware' do
      @base.set :method_override, true
      @base.put('/') { 'okay' }
      @app = @base
      post '/', {'_method'=>'PUT'}, {}
      assert_equal 200, status
      assert_equal 'okay', body
    end

    it 'is backward compatible with methodoverride' do
      assert ! @base.methodoverride?
      @base.enable :methodoverride
      assert @base.methodoverride?
    end
  end

  describe 'run' do
    it 'is disabled on Base' do
      assert ! @base.run?
    end

    it 'is enabled on Application except in test environment' do
      assert @application.run?

      @application.set :environment, :test
      assert ! @application.run?
    end
  end

  describe 'raise_errors' do
    it 'is enabled on Base only in test' do
      assert ! @base.raise_errors?

      @base.set(:environment, :test)
      assert @base.raise_errors?
    end

    it 'is enabled on Application only in test' do
      assert ! @application.raise_errors?

      @application.set(:environment, :test)
      assert @application.raise_errors?
    end
  end

  describe 'show_exceptions' do
    it 'is disabled on Base except under development' do
      assert ! @base.show_exceptions?
      @base.environment = :development
      assert @base.show_exceptions?
    end

    it 'is disabled on Application except in development' do
      assert ! @application.show_exceptions?

      @application.set(:environment, :development)
      assert @application.show_exceptions?
    end

    it 'returns a friendly 500' do
      klass = Sinatra.new(Sinatra::Application)
      mock_app(klass) {
        enable :show_exceptions

        get '/' do
          raise StandardError
        end
      }

      get '/'
      assert_equal 500, status
      assert body.include?("StandardError")
      assert body.include?("<code>show_exceptions</code> setting")
    end

    it 'does not override app-specified error handling when set to :after_handler' do
      klass = Sinatra.new(Sinatra::Application)
      mock_app(klass) {
        set :show_exceptions, :after_handler
        
        error RuntimeError do
          'Big mistake !'
        end
        
        get '/' do
          raise RuntimeError
        end  
      }
      
      get '/'
      assert_equal 500, status

      assert ! body.include?("<code>")
      assert body.include? "Big mistake !"
      
    end
    
  end

  describe 'dump_errors' do
    it 'is disabled on Base in test' do
      @base.environment = :test
      assert ! @base.dump_errors?
      @base.environment = :development
      assert @base.dump_errors?
      @base.environment = :production
      assert @base.dump_errors?
    end

    it 'dumps exception with backtrace to rack.errors' do
      klass = Sinatra.new(Sinatra::Application)

      mock_app(klass) {
        enable :dump_errors
        disable :raise_errors

        error do
          error = @env['rack.errors'].instance_variable_get(:@error)
          error.rewind

          error.read
        end

        get '/' do
          raise
        end
      }

      get '/'
      assert body.include?("RuntimeError") && body.include?("settings_test.rb")
    end
  end

  describe 'sessions' do
    it 'is disabled on Base' do
      assert ! @base.sessions?
    end

    it 'is disabled on Application' do
      assert ! @application.sessions?
    end
  end

  describe 'logging' do
    it 'is disabled on Base' do
      assert ! @base.logging?
    end

    it 'is enabled on Application except in test environment' do
      assert @application.logging?

      @application.set :environment, :test
      assert ! @application.logging
    end
  end

  describe 'static' do
    it 'is disabled on Base by default' do
      assert ! @base.static?
    end

    it 'is enabled on Base when public is set and exists' do
      @base.set :environment, :development
      @base.set :public, File.dirname(__FILE__)
      assert @base.static?
    end

    it 'is enabled on Base when root is set and root/public exists' do
      @base.set :environment, :development
      @base.set :root, File.dirname(__FILE__)
      assert @base.static?
    end

    it 'is disabled on Application by default' do
      assert ! @application.static?
    end

    it 'is enabled on Application when public is set and exists' do
      @application.set :environment, :development
      @application.set :public, File.dirname(__FILE__)
      assert @application.static?
    end

    it 'is enabled on Application when root is set and root/public exists' do
      @application.set :environment, :development
      @application.set :root, File.dirname(__FILE__)
      assert @application.static?
    end
  end

  describe 'bind' do
    it 'defaults to 0.0.0.0' do
      assert_equal '0.0.0.0', @base.bind
      assert_equal '0.0.0.0', @application.bind
    end
  end

  describe 'port' do
    it 'defaults to 4567' do
      assert_equal 4567, @base.port
      assert_equal 4567, @application.port
    end
  end

  describe 'server' do
    it 'is one of thin, mongrel, webrick' do
      assert_equal %w[thin mongrel webrick], @base.server
      assert_equal %w[thin mongrel webrick], @application.server
    end
  end

  describe 'app_file' do
    it 'is nil' do
      assert_nil @base.app_file
      assert_nil @application.app_file
    end
  end

  describe 'root' do
    it 'is nil if app_file is not set' do
      assert @base.root.nil?
      assert @application.root.nil?
    end

    it 'is equal to the expanded basename of app_file' do
      @base.app_file = __FILE__
      assert_equal File.expand_path(File.dirname(__FILE__)), @base.root

      @application.app_file = __FILE__
      assert_equal File.expand_path(File.dirname(__FILE__)), @application.root
    end
  end

  describe 'views' do
    it 'is nil if root is not set' do
      assert @base.views.nil?
      assert @application.views.nil?
    end

    it 'is set to root joined with views/' do
      @base.root = File.dirname(__FILE__)
      assert_equal File.dirname(__FILE__) + "/views", @base.views

      @application.root = File.dirname(__FILE__)
      assert_equal File.dirname(__FILE__) + "/views", @application.views
    end
  end

  describe 'public' do
    it 'is nil if root is not set' do
      assert @base.public.nil?
      assert @application.public.nil?
    end

    it 'is set to root joined with public/' do
      @base.root = File.dirname(__FILE__)
      assert_equal File.dirname(__FILE__) + "/public", @base.public

      @application.root = File.dirname(__FILE__)
      assert_equal File.dirname(__FILE__) + "/public", @application.public
    end
  end

  describe 'lock' do
    it 'is disabled by default' do
      assert ! @base.lock?
      assert ! @application.lock?
    end
  end
end
