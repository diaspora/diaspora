module Capistrano
  class Role
    include Enumerable

    def initialize(*list)
      @static_servers = []
      @dynamic_servers = []
      push(*list)
    end

    def each(&block)
      servers.each &block
    end

    def push(*list)
      options = list.last.is_a?(Hash) ? list.pop : {}
      list.each do |item|
        if item.respond_to?(:call)
          @dynamic_servers << DynamicServerList.new(item, options)
        else
          @static_servers << self.class.wrap_server(item, options)
        end
      end
    end
    alias_method :<<, :push

    def servers
      @static_servers + dynamic_servers
    end
    alias_method :to_ary, :servers

    def empty?
      servers.empty?
    end

    def clear
      @dynamic_servers.clear
      @static_servers.clear
    end

    def include?(server)
      servers.include?(server)
    end

    protected

    # This is the combination of a block, a hash of options, and a cached value.
    class DynamicServerList
      def initialize (block, options)
        @block = block
        @options = options
        @cached = []
        @is_cached = false
      end

      # Convert to a list of ServerDefinitions
      def to_ary
        unless @is_cached
          @cached = Role::wrap_list(@block.call(@options), @options)
          @is_cached = true
        end
        @cached
      end

      # Clear the cached value
      def reset!
        @cached.clear
        @is_cached = false
      end
    end

    # Attribute reader for the cached results of executing the blocks in turn
    def dynamic_servers
      @dynamic_servers.inject([]) { |list, item| list.concat item }
    end

    # Wraps a string in a ServerDefinition, if it isn't already.
    # This and wrap_list should probably go in ServerDefinition in some form.
    def self.wrap_server (item, options)
      item.is_a?(ServerDefinition) ? item : ServerDefinition.new(item, options)
    end

    # Turns a list, or something resembling a list, into a properly-formatted
    # ServerDefinition list. Keep an eye on this one -- it's entirely too
    # magical for its own good. In particular, if ServerDefinition ever inherits
    # from Array, this will break.
    def self.wrap_list (*list)
      options = list.last.is_a?(Hash) ? list.pop : {}
      if list.length == 1
        if list.first.nil?
          return []
        elsif list.first.is_a?(Array)
          list = list.first
        end
      end
      options.merge! list.pop if list.last.is_a?(Hash)
      list.map do |item|
        self.wrap_server item, options
      end
    end
  end
end
