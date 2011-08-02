module Fog
  class Collection < Array

    extend Fog::Attributes::ClassMethods
    include Fog::Attributes::InstanceMethods

    Array.public_instance_methods(false).each do |method|
      unless [:reject, :select].include?(method.to_sym)
        class_eval <<-RUBY
          def #{method}(*args)
            unless @loaded
              lazy_load
            end
            super
          end
        RUBY
      end
    end

    %w[reject select].each do |method|
      class_eval <<-RUBY
        def #{method}(*args)
          unless @loaded
            lazy_load
          end
          data = super
          result = self.clone.clear.concat(data)
        end
      RUBY
    end

    def self.model(new_model=nil)
      if new_model == nil
        @model
      else
        @model = new_model
      end
    end

    attr_accessor :connection

    remove_method :clear
    def clear
      @loaded = true
      super
    end

    def create(attributes = {})
      object = new(attributes)
      object.save
      object
    end

    def initialize(attributes = {})
      @loaded = false
      merge_attributes(attributes)
    end

    remove_method :inspect
    def inspect
      Thread.current[:formatador] ||= Formatador.new
      data = "#{Thread.current[:formatador].indentation}<#{self.class.name}\n"
      Thread.current[:formatador].indent do
        unless self.class.attributes.empty?
          data << "#{Thread.current[:formatador].indentation}"
          data << self.class.attributes.map {|attribute| "#{attribute}=#{send(attribute).inspect}"}.join(",\n#{Thread.current[:formatador].indentation}")
          data << "\n"
        end
        data << "#{Thread.current[:formatador].indentation}["
        unless self.empty?
          data << "\n"
          Thread.current[:formatador].indent do
            data << self.map {|member| member.inspect}.join(",\n")
            data << "\n"
          end
          data << Thread.current[:formatador].indentation
        end
        data << "]\n"
      end
      data << "#{Thread.current[:formatador].indentation}>"
      data
    end

    def load(objects)
      clear
      for object in objects
        self << new(object)
      end
      self
    end

    def model
      self.class.instance_variable_get('@model')
    end

    def new(attributes = {})
      model.new(
        attributes.merge(
          :collection => self,
          :connection => connection
        )
      )
    end

    def reload
      clear
      lazy_load
      self
    end

    def table(attributes = nil)
      Formatador.display_table(self.map {|instance| instance.attributes}, attributes)
    end

    def to_json
      self.map {|member| member.attributes}.to_json
    end

    private

    def lazy_load
      self.all
    end

  end
end
