module Fog
  class Storage

    def self.new(attributes)
      case provider = attributes.delete(:provider)
      when 'AWS'
        require 'fog/aws'
        Fog::AWS::Storage.new(attributes)
      when 'Google'
        require 'fog/google'
        Fog::Google::Storage.new(attributes)
      when 'Local'
        require 'fog/local'
        Fog::Local::Storage.new(attributes)
      when 'Rackspace'
        require 'fog/rackspace'
        Fog::Rackspace::Storage.new(attributes)
      else
        raise ArgumentError.new("#{provider} is not a recognized storage provider")
      end
    end

  end
end
