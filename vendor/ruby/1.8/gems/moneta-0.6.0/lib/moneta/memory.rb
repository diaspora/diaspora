module Moneta
  class Memory < Hash
    include Expires
    
    def initialize(*args)
      @expiration = {}
      super
    end    
        
  end
end