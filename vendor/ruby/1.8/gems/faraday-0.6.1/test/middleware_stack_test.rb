require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class MiddlewareStackTest < Faraday::TestCase
  # mock handler classes
  class Handler < Struct.new(:app)
    def call(env)
      (env[:request_headers]['X-Middleware'] ||= '') << ":#{self.class.name.split('::').last}"
      app.call(env)
    end
  end
  class Apple < Handler; end
  class Orange < Handler; end
  class Banana < Handler; end

  def setup
    @conn = Faraday::Connection.new
    @builder = @conn.builder
  end

  def test_sets_default_adapter_if_none_set
    default_middleware = Faraday::Request.lookup_module :url_encoded
    default_adapter_klass = Faraday::Adapter.lookup_module Faraday.default_adapter
    assert @builder[0] == default_middleware
    assert @builder[1] == default_adapter_klass
  end

  def test_allows_rebuilding
    build_stack Apple
    assert_handlers %w[Apple]

    build_stack Orange
    assert_handlers %w[Orange]
  end

  def test_allows_extending
    build_stack Apple
    @conn.use Orange
    assert_handlers %w[Apple Orange]
  end

  def test_builder_is_passed_to_new_faraday_connection
    new_conn = Faraday::Connection.new :builder => @builder
    assert_equal @builder, new_conn.builder
  end

  def test_insert_before
    build_stack Apple, Orange
    @builder.insert_before Apple, Banana
    assert_handlers %w[Banana Apple Orange]
  end

  def test_insert_after
    build_stack Apple, Orange
    @builder.insert_after Apple, Banana
    assert_handlers %w[Apple Banana Orange]
  end

  def test_swap_handlers
    build_stack Apple, Orange
    @builder.swap Apple, Banana
    assert_handlers %w[Banana Orange]
  end

  def test_delete_handler
    build_stack Apple, Orange
    @builder.delete Apple
    assert_handlers %w[Orange]
  end

  private

  # make a stack with test adapter that reflects the order of middleware
  def build_stack(*handlers)
    @builder.build do |b|
      handlers.each { |handler| b.use(*handler) }

      b.adapter :test do |stub|
        stub.get '/' do |env|
          # echo the "X-Middleware" request header in the body
          [200, {}, env[:request_headers]['X-Middleware'].to_s]
        end
      end
    end
  end

  def assert_handlers(list)
    echoed_list = @conn.get('/').body.to_s.split(':')
    echoed_list.shift if echoed_list.first == ''
    assert_equal list, echoed_list
  end
end
