module Fog
  module Attributes
    module ClassMethods

      def _load(marshalled)
        new(Marshal.load(marshalled))
      end

      def aliases
        @aliases ||= {}
      end

      def attributes
        @attributes ||= []
      end

      def attribute(name, options = {})
        class_eval <<-EOS, __FILE__, __LINE__
          def #{name}
            attributes[:#{name}]
          end
        EOS
        case options[:type]
        when :boolean
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = case new_#{name}
              when 'true'
                true
              when 'false'
                false
              end
            end
          EOS
        when :float
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_f
            end
          EOS
        when :integer
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_i
            end
          EOS
        when :string
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = new_#{name}.to_s
            end
          EOS
        when :time
          class_eval <<-EOS, __FILE__, __LINE__
            def #{name}=(new_#{name})
              attributes[:#{name}] = if new_#{name}.nil? || new_#{name} == "" || new_#{name}.is_a?(Time)
                new_#{name}
              else
                Time.parse(new_#{name})
              end
            end
          EOS
        when :array
          class_eval <<-EOS, __FILE__, __LINE__
          def #{name}=(new_#{name})
            attributes[:#{name}] = [*new_#{name}]
          end
          EOS
        else
          if squash = options[:squash]
            class_eval <<-EOS, __FILE__, __LINE__
              def #{name}=(new_data)
                if new_data.is_a?(Hash)
                  if new_data[:#{squash}] || new_data["#{squash}"]
                    attributes[:#{name}] = new_data[:#{squash}] || new_data["#{squash}"]
                  else
                    attributes[:#{name}] = [ new_data ]
                  end
                else
                  attributes[:#{name}] = new_data
                end
              end
            EOS
          else
            class_eval <<-EOS, __FILE__, __LINE__
              def #{name}=(new_#{name})
                attributes[:#{name}] = new_#{name}
              end
            EOS
          end
        end
        @attributes ||= []
        @attributes |= [name]
        for new_alias in [*options[:aliases]]
          aliases[new_alias] = name
        end
      end

      def identity(name, options = {})
        @identity = name
        self.attribute(name, options)
      end

      def ignore_attributes(*args)
        @ignored_attributes = args
      end

      def ignored_attributes
        @ignored_attributes ||= []
      end

    end

    module InstanceMethods

      def _dump
        Marshal.dump(attributes)
      end

      def attributes
        @attributes ||= {}
      end

      def identity
        send(self.class.instance_variable_get('@identity'))
      end

      def identity=(new_identity)
        send("#{self.class.instance_variable_get('@identity')}=", new_identity)
      end

      def merge_attributes(new_attributes = {})
        for key, value in new_attributes
          unless self.class.ignored_attributes.include?(key)
            if aliased_key = self.class.aliases[key]
              send("#{aliased_key}=", value)
            elsif (public_methods | private_methods).detect {|method| ["#{key}=", :"#{key}="].include?(method)}
              send("#{key}=", value)
            else
              attributes[key] = value
            end
          end
        end
        self
      end

      def new_record?
        !identity
      end

      def requires(*args)
        missing = []
        for arg in [:connection] | args
          missing << arg unless send("#{arg}")
        end
        unless missing.empty?
          if missing.length == 1
            raise(ArgumentError, "#{missing.first} is required for this operation")
          else
            raise(ArgumentError, "#{missing[0...-1].join(", ")} and #{missing[-1]} are required for this operation")
          end
        end
      end

      private

      def remap_attributes(attributes, mapping)
        for key, value in mapping
          if attributes.key?(key)
            attributes[value] = attributes.delete(key)
          end
        end
      end

    end
  end
end
