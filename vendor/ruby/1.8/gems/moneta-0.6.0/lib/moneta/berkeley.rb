begin
  require 'bdb'
rescue LoadError
  puts "You need bdb gem to use Bdb moneta store"
  exit
end

module Moneta

  class Berkeley
    include Defaults

    def initialize(options={})
      file = @file = options[:file]
      @db = Bdb::Db.new()
      @db.open(nil, file, nil, Bdb::Db::BTREE, Bdb::DB_CREATE, 0)
      unless options[:skip_expires]
        @expiration = Moneta::Berkeley.new(:file => "#{file}_expiration", :skip_expires => true )
        self.extend(StringExpires)
      end
    end
    
    module Implementation
      def key?(key)
        nil | self[key]
      end

      alias has_key? key?

      def []=(key,value)
        @db[key] = value
      end

      def [](key)
        @db[key]
      end

      def delete(key)
        value = self[key]
        @db.del(nil,key,0) if value
        value
      end

      def clear
        @db.truncate(nil)
      end
    end

    include Implementation

  end

end
