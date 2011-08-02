module Fog
  class Model

    extend Fog::Attributes::ClassMethods
    include Fog::Attributes::InstanceMethods

    attr_accessor :collection, :connection

    def initialize(new_attributes = {})
      merge_attributes(new_attributes)
    end

    def inspect
      Thread.current[:formatador] ||= Formatador.new
      data = "#{Thread.current[:formatador].indentation}<#{self.class.name}"
      Thread.current[:formatador].indent do
        unless self.class.attributes.empty?
          data << "\n#{Thread.current[:formatador].indentation}"
          data << self.class.attributes.map {|attribute| "#{attribute}=#{send(attribute).inspect}"}.join(",\n#{Thread.current[:formatador].indentation}")
        end
      end
      data << "\n#{Thread.current[:formatador].indentation}>"
      data
    end

    def reload
      requires :identity
      if data = collection.get(identity)
        new_attributes = data.attributes
        merge_attributes(new_attributes)
        self
      end
    end

    def to_json
      attributes.to_json
    end

    def wait_for(timeout=600, interval=1, &block)
      reload
      Fog.wait_for(timeout, interval) do
        reload or raise Fog::Errors::Error.new("Reload failed, #{self.class} #{self.identity} went away.")
        instance_eval(&block)
      end
    end

  end
end
