require 'active_support/core_ext'
require 'active_model'

module RSpec
  module Rails

    class IllegalDataAccessException < StandardError; end

    module Mocks

      module ActiveModelInstanceMethods
        def as_new_record
          self.stub(:persisted?) { false }
          self.stub(:id) { nil }
          self
        end

        def persisted?
          true
        end

        def respond_to?(message, include_private=false)
          message.to_s =~ /_before_type_cast$/ ? false : super
        end
      end

      module ActiveRecordInstanceMethods
        def destroy
          self.stub(:persisted?) { false }
          self.stub(:id) { nil }
        end

        def [](key)
          send(key)
        end

        def new_record?
          !persisted?
        end
      end

      # Creates a test double representing +string_or_model_class+ with common
      # ActiveModel methods stubbed out. Additional methods may be easily
      # stubbed (via add_stubs) if +stubs+ is passed. This is most useful for
      # impersonating models that don't exist yet.
      #
      # NOTE that only ActiveModel's methods, plus <tt>new_record?</tt>, are
      # stubbed out implicitly.  <tt>new_record?</tt> returns the inverse of
      # <tt>persisted?</tt>, and is present only for compatibility with
      # extension frameworks that have yet to update themselves to the
      # ActiveModel API (which declares <tt>persisted?</tt>, not
      # <tt>new_record?</tt>).
      #
      # +string_or_model_class+ can be any of:
      #
      #   * A String representing a Class that does not exist
      #   * A String representing a Class that extends ActiveModel::Naming
      #   * A Class that extends ActiveModel::Naming
      def mock_model(string_or_model_class, stubs = {})
        if String === string_or_model_class
          if Object.const_defined?(string_or_model_class)
            model_class = Object.const_get(string_or_model_class)
          else
            model_class = Object.const_set(string_or_model_class, Class.new do
              extend ActiveModel::Naming
            end)
          end
        else
          model_class = string_or_model_class
        end

        unless model_class.kind_of? ActiveModel::Naming
          raise ArgumentError.new <<-EOM
The mock_model method can only accept as its first argument:
  * A String representing a Class that does not exist
  * A String representing a Class that extends ActiveModel::Naming
  * A Class that extends ActiveModel::Naming

It received #{model_class.inspect}
EOM
        end

        stubs = stubs.reverse_merge(:id => next_id)
        stubs = stubs.reverse_merge(:persisted? => !!stubs[:id])
        stubs = stubs.reverse_merge(:destroyed? => false)
        stubs = stubs.reverse_merge(:marked_for_destruction? => false)
        stubs = stubs.reverse_merge(:blank? => false)

        mock("#{model_class.name}_#{stubs[:id]}", stubs).tap do |m|
          m.extend ActiveModelInstanceMethods
          m.singleton_class.__send__ :include, ActiveModel::Conversion
          m.singleton_class.__send__ :include, ActiveModel::Validations
          if defined?(ActiveRecord)
            m.extend ActiveRecordInstanceMethods
            [:save, :update_attributes].each do |key|
              if stubs[key] == false
                m.errors.stub(:empty?) { false }
              end
            end
          end
          m.__send__(:__mock_proxy).instance_eval(<<-CODE, __FILE__, __LINE__)
            def @object.is_a?(other)
              #{model_class}.ancestors.include?(other)
            end
            def @object.kind_of?(other)
              #{model_class}.ancestors.include?(other)
            end
            def @object.instance_of?(other)
              other == #{model_class}
            end
            def @object.respond_to?(method_name, include_private=false)
              #{model_class}.respond_to?(:column_names) && #{model_class}.column_names.include?(method_name.to_s) || super
            end
            def @object.class
              #{model_class}
            end
            def @object.to_s
              "#{model_class.name}_#{to_param}"
            end
          CODE
          yield m if block_given?
        end
      end

      module ActiveModelStubExtensions
        def as_new_record
          self.stub(:persisted?)  { false }
          self.stub(:id)          { nil }
          self
        end

        def persisted?
          true
        end
      end

      module ActiveRecordStubExtensions
        def as_new_record
          self.__send__("#{self.class.primary_key}=", nil)
          super
        end

        def new_record?
          !persisted?
        end

        def connection
          raise RSpec::Rails::IllegalDataAccessException.new("stubbed models are not allowed to access the database")
        end
      end

      # :call-seq:
      #   stub_model(Model)
      #   stub_model(Model).as_new_record
      #   stub_model(Model, hash_of_stubs)
      #   stub_model(Model, instance_variable_name, hash_of_stubs)
      #
      # Creates an instance of +Model+ with +to_param+ stubbed using a
      # generated value that is unique to each object.. If +Model+ is an
      # +ActiveRecord+ model, it is prohibited from accessing the database*.
      #
      # For each key in +hash_of_stubs+, if the model has a matching attribute
      # (determined by asking it) are simply assigned the submitted values. If
      # the model does not have a matching attribute, the key/value pair is
      # assigned as a stub return value using RSpec's mocking/stubbing
      # framework.
      #
      # <tt>persisted?</tt> is overridden to return the result of !id.nil?
      # This means that by default persisted? will return true. If  you want
      # the object to behave as a new record, sending it +as_new_record+ will
      # set the id to nil. You can also explicitly set :id => nil, in which
      # case persisted? will return false, but using +as_new_record+ makes the
      # example a bit more descriptive.
      #
      # While you can use stub_model in any example (model, view, controller,
      # helper), it is especially useful in view examples, which are
      # inherently more state-based than interaction-based.
      #
      # == Examples
      #
      #   stub_model(Person)
      #   stub_model(Person).as_new_record
      #   stub_model(Person, :to_param => 37)
      #   stub_model(Person) do |person|
      #     person.first_name = "David"
      #   end
      def stub_model(model_class, stubs={})
        model_class.new.tap do |m|
          m.extend ActiveModelStubExtensions
          if defined?(ActiveRecord) && model_class < ActiveRecord::Base
            m.extend ActiveRecordStubExtensions
            primary_key = model_class.primary_key.to_sym
            stubs = stubs.reverse_merge(primary_key => next_id)
            stubs = stubs.reverse_merge(:persisted? => !!stubs[primary_key])
          else
            stubs = stubs.reverse_merge(:id => next_id)
            stubs = stubs.reverse_merge(:persisted? => !!stubs[:id])
          end
          stubs = stubs.reverse_merge(:blank? => false)
          stubs.each do |k,v|
            m.__send__("#{k}=", stubs.delete(k)) if m.respond_to?("#{k}=")
          end
          m.stub(stubs)
          yield m if block_given?
        end
      end

    private

      @@model_id = 1000

      def next_id
        @@model_id += 1
      end

    end
  end
end

RSpec.configure do |c|
  c.include RSpec::Rails::Mocks
end

