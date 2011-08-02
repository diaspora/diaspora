module Capistrano
  class ServerDefinition
    include Comparable

    attr_reader :host
    attr_reader :user
    attr_reader :port
    attr_reader :options

    # The default user name to use when a user name is not explicitly provided
    def self.default_user
      ENV['USER'] || ENV['USERNAME'] || "not-specified"
    end

    def initialize(string, options={})
      @user, @host, @port = string.match(/^(?:([^;,:=]+)@|)(.*?)(?::(\d+)|)$/)[1,3]

      @options = options.dup
      user_opt, port_opt = @options.delete(:user), @options.delete(:port)

      @user ||= user_opt
      @port ||= port_opt

      @port = @port.to_i if @port
    end

    def <=>(server)
      [host, port, user] <=> [server.host, server.port, server.user]
    end

    # Redefined, so that Array#uniq will work to remove duplicate server
    # definitions, based solely on their host names.
    def eql?(server)
      host == server.host &&
        user == server.user &&
        port == server.port
    end

    alias :== :eql?

    # Redefined, so that Array#uniq will work to remove duplicate server
    # definitions, based on their connection information.
    def hash
      @hash ||= [host, user, port].hash
    end

    def to_s
      @to_s ||= begin
        s = host
        s = "#{user}@#{s}" if user
        s = "#{s}:#{port}" if port && port != 22
        s
      end
    end
  end
end