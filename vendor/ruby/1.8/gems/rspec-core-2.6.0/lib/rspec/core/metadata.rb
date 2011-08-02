module RSpec
  module Core
    class Metadata < Hash

      module LocationKeys
        def [](key)
          return super if has_key?(key)
          case key
          when :location
            store(:location, location)
          when :file_path, :line_number
            file_path, line_number = file_and_line_number
            store(:file_path, file_path)
            store(:line_number, line_number)
            self[key]
          else
            super
          end
        end

        def location
          "#{self[:file_path]}:#{self[:line_number]}"
        end

        def file_and_line_number
          first_caller_from_outside_rspec =~ /(.+?):(\d+)(|:\d+)/
          return [$1, $2.to_i]
        end

        def first_caller_from_outside_rspec
          self[:caller].detect {|l| l !~ /\/lib\/rspec\/core/}
        end
      end

      def initialize(superclass_metadata=nil)
        @superclass_metadata = superclass_metadata
        if @superclass_metadata
          update(@superclass_metadata)
          example_group = {:example_group => @superclass_metadata[:example_group]}
        else
          example_group = {}
        end

        store(:example_group, example_group.extend(LocationKeys))
        yield self if block_given?
      end

      RESERVED_KEYS = [
        :description,
        :example_group,
        :execution_result,
        :file_path,
        :full_description,
        :line_number,
        :location
      ]

      def process(*args)
        user_metadata = args.last.is_a?(Hash) ? args.pop : {}
        ensure_valid_keys(user_metadata)

        self[:example_group].store(:caller, user_metadata.delete(:caller) || caller)
        self[:example_group].store(:describes, described_class_from(*args))
        self[:example_group].store(:description, description_from(*args))
        self[:example_group].store(:full_description, full_description_from(*args))
        self[:example_group].store(:block, user_metadata.delete(:example_group_block))

        update(user_metadata)
      end

      def ensure_valid_keys(user_metadata)
        RESERVED_KEYS.each do |key|
          if user_metadata.keys.include?(key)
            raise <<-EOM
#{"*"*50}
:#{key} is not allowed

RSpec reserves some hash keys for its own internal use,
including :#{key}, which is used on:

  #{caller(0)[4]}.

Here are all of RSpec's reserved hash keys:

  #{RESERVED_KEYS.join("\n  ")}
#{"*"*50}
EOM
            raise ":#{key} is not allowed"
          end
        end
      end

      def for_example(description, user_metadata)
        dup.extend(LocationKeys).configure_for_example(description, user_metadata)
      end

      def configure_for_example(description, user_metadata)
        store(:description, description.to_s)
        store(:full_description, "#{self[:example_group][:full_description]} #{self[:description]}")
        store(:execution_result, {})
        store(:caller, user_metadata.delete(:caller) || caller)
        update(user_metadata)
      end

      def apply?(predicate, filters)
        filters.send(predicate) do |key, value|
          apply_condition(key, value)
        end
      end

      def relevant_line_numbers(metadata)
        line_numbers = [metadata[:line_number]]
        if metadata[:example_group]
          line_numbers + relevant_line_numbers(metadata[:example_group])
        else
          line_numbers
        end
      end

      def apply_condition(key, value, metadata=self)
        case value
        when Hash
          value.all? { |k, v| apply_condition(k, v, metadata[key]) }
        when Regexp
          metadata[key] =~ value
        when Proc
          if value.arity == 2
            # Pass the metadata hash to allow the proc to check if it even has the key.
            # This is necessary for the implicit :if exclusion filter:
            #   {            } # => run the example
            #   { :if => nil } # => exclude the example
            # The value of metadata[:if] is the same in these two cases but
            # they need to be treated differently.
            value.call(metadata[key], metadata) rescue false
          else
            value.call(metadata[key]) rescue false
          end
        when Fixnum
          if key == :line_number
            relevant_line_numbers(metadata).include?(world.preceding_declaration_line(value))
          else
            metadata[key] == value
          end
        else
          metadata[key].to_s == value.to_s
        end
      end

    private

      def world
        RSpec.world
      end

      def superclass_metadata
        @superclass_metadata ||= { :example_group => {} }
      end

      def description_from(*args)
        args.inject("") do |result, a|
          a = a.to_s.strip
          if result == ""
            a
          elsif a =~ /^(#|::|\.)/
            "#{result}#{a}"
          else
            "#{result} #{a}"
          end
        end
      end

      def full_description_from(*args)
        if superclass_metadata[:example_group][:full_description]
          description_from(superclass_metadata[:example_group][:full_description], *args)
        else
          description_from(*args)
        end
      end

      def described_class_from(*args)
        superclass_metadata[:example_group][:describes] || begin
          args.first unless args.first.is_a?(String) || args.first.is_a?(Symbol)
        end
      end
    end
  end
end
