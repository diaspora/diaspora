require 'scanf'
module Capistrano

  class Version

    CURRENT = File.read(File.dirname(__FILE__) + '/../../VERSION')

    MAJOR, MINOR, TINY = CURRENT.scanf('%d.%d.%d')

    STRING = CURRENT.to_s

    def self.to_s
      CURRENT
    end
    
  end

end
