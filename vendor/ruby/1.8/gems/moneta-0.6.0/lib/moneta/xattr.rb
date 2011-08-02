begin
  require "xattr"
rescue LoadError
  puts "You need the xattr gem to use the Xattr moneta store"
  exit
end
require "fileutils"

module Moneta
  class Xattr
    include Defaults
    
    def initialize(options = {})
      file = options[:file]
      @hash = ::Xattr.new(file)
      FileUtils.mkdir_p(::File.dirname(file))
      FileUtils.touch(file)
      unless options[:skip_expires]
        @expiration = Moneta::Xattr.new(:file => "#{file}_expiration", :skip_expires => true)
        self.extend(Expires)
      end
    end
    
    module Implementation
      
      def key?(key)
        @hash.list.include?(key)
      end
      
      alias has_key? key?
      
      def [](key)
        return nil unless key?(key)
        Marshal.load(@hash.get(key))
      end
      
      def []=(key, value)
        @hash.set(key, Marshal.dump(value))
      end
      
      def delete(key)
        return nil unless key?(key)
        value = self[key]
        @hash.remove(key)
        value
      end
      
      def clear
        @hash.list.each do |item|
          @hash.remove(item)
        end
      end
      
    end
    include Implementation
    
  end
end