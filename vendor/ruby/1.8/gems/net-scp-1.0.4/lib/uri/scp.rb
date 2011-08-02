require 'uri/generic'

module URI
  class SCP < Generic
    DEFAULT_PORT = 22

    COMPONENT = [
      :scheme,
      :userinfo,
      :host, :port, :path,
      :query  
    ].freeze

    attr_reader :options

    def self.new2(user, password, host, port, path, query)
      new('scp', [user, password], host, port, nil, path, nil, query)
    end

    def initialize(*args)
      super(*args)

      @options = Hash.new
      (query || "").split(/&/).each do |pair|
        name, value = pair.split(/=/, 2)
        opt_name = name.to_sym
        values = value.split(/,/).map { |v| v.to_i.to_s == v ? v.to_i : v }
        values = values.first if values.length == 1
        options[opt_name] = values
      end
    end
  end

  @@schemes['SCP'] = SCP
end