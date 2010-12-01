require "sdbm"

module Moneta
  class BasicSDBM < ::SDBM
    include Defaults

    def [](key)
      if val = super
        Marshal.load(val)
      end
    end

    def []=(key, value)
      super(key, Marshal.dump(value))
    end

    def delete(key)
      if val = super
        Marshal.load(val)
      end
    end
  end

  class SDBM < BasicSDBM
    include Expires

    def initialize(options = {})
      raise "No :file option specified" unless file = options[:file]
      @expiration = BasicSDBM.new("#{file}_expires")
      super(file)
    end
  end
end