require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestConnectionApps < Faraday::TestCase
  class TestAdapter
    def initialize(app)
      @app = app
    end

    def call(env)
      [200, {}, env[:test]]
    end
  end

  class TestMiddleWare
    def initialize(app)
      @app = app
    end

    def call(env)
      env[:test] = 'hi'
      @app.call(env)
    end
  end

  def setup
    @conn = Faraday::Connection.new do |b|
      b.use TestMiddleWare
      b.use TestAdapter
    end
  end

  def test_builder_is_built_from_faraday_connection
    assert_kind_of Faraday::Builder, @conn.builder
    assert_equal 3, @conn.builder.handlers.size
  end

  def test_builder_adds_middleware_to_builder_stack
    assert_kind_of TestMiddleWare, @conn.builder[0].call(nil)
    assert_kind_of TestAdapter,    @conn.builder[1].call(nil)
  end

  def test_to_app_returns_rack_object
    assert @conn.to_app.respond_to?(:call)
  end

  def test_builder_is_passed_to_new_faraday_connection
    new_conn = Faraday::Connection.new :builder => @conn.builder
    assert_equal @conn.builder, new_conn.builder
  end

  def test_builder_is_built_on_new_faraday_connection
    new_conn = Faraday::Connection.new
    new_conn.build do |b|
      b.run @conn.builder[0]
      b.run @conn.builder[1]
    end
    assert_kind_of TestMiddleWare, new_conn.builder[0].call(nil)
    assert_kind_of TestAdapter,    new_conn.builder[1].call(nil)
  end
end
