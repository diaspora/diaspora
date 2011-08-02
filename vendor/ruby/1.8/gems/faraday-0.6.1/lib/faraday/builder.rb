module Faraday
  # Possibly going to extend this a bit.
  #
  # Faraday::Connection.new(:url => 'http://sushi.com') do |builder|
  #   builder.request  :url_encoded  # Faraday::Request::UrlEncoded
  #   builder.adapter  :net_http     # Faraday::Adapter::NetHttp
  # end
  class Builder
    attr_accessor :handlers

    def self.create
      new { |builder| yield builder }
    end

    # borrowed from ActiveSupport::Dependencies::Reference &
    # ActionDispatch::MiddlewareStack::Middleware
    class Handler
      @@constants = Hash.new { |h, k|
        h[k] = k.respond_to?(:constantize) ? k.constantize : Object.const_get(k)
      }

      attr_reader :name

      def initialize(klass, *args, &block)
        @name = klass.to_s
        @@constants[@name] = klass if klass.respond_to?(:name)
        @args, @block = args, block
      end

      def klass() @@constants[@name] end
      def inspect() @name end

      def ==(other)
        if other.respond_to? :name
          klass == other
        else
          @name == other.to_s
        end
      end

      def build(app)
        klass.new(app, *@args, &@block)
      end
    end

    def initialize(handlers = [])
      @handlers = handlers
      if block_given?
        build(&Proc.new)
      elsif @handlers.empty?
        # default stack, if nothing else is configured
        self.request :url_encoded
        self.adapter Faraday.default_adapter
      end
    end

    def build(options = {})
      @handlers.clear unless options[:keep]
      yield self if block_given?
    end

    def [](idx)
      @handlers[idx]
    end

    def ==(other)
      other.is_a?(self.class) && @handlers == other.handlers
    end

    def dup
      self.class.new(@handlers.dup)
    end

    def to_app(inner_app)
      # last added handler is the deepest and thus closest to the inner app
      @handlers.reverse.inject(inner_app) { |app, handler| handler.build(app) }
    end

    def use(klass, *args)
      block = block_given? ? Proc.new : nil
      @handlers << self.class::Handler.new(klass, *args, &block)
    end

    def request(key, *args)
      block = block_given? ? Proc.new : nil
      use_symbol(Faraday::Request, key, *args, &block)
    end

    def response(key, *args)
      block = block_given? ? Proc.new : nil
      use_symbol(Faraday::Response, key, *args, &block)
    end

    def adapter(key, *args)
      block = block_given? ? Proc.new : nil
      use_symbol(Faraday::Adapter, key, *args, &block)
    end

    ## methods to push onto the various positions in the stack:

    def insert(index, *args, &block)
      index = assert_index(index)
      handler = self.class::Handler.new(*args, &block)
      @handlers.insert(index, handler)
    end

    alias_method :insert_before, :insert

    def insert_after(index, *args, &block)
      index = assert_index(index)
      insert(index + 1, *args, &block)
    end

    def swap(index, *args, &block)
      index = assert_index(index)
      @handlers.delete_at(index)
      insert(index, *args, &block)
    end

    def delete(handler)
      @handlers.delete(handler)
    end

    private

    def use_symbol(mod, key, *args)
      block = block_given? ? Proc.new : nil
      use(mod.lookup_module(key), *args, &block)
    end

    def assert_index(index)
      idx = index.is_a?(Integer) ? index : @handlers.index(index)
      raise "No such handler: #{index.inspect}" unless idx
      idx
    end
  end
end
