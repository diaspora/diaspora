module YARD
  module CLI
    # CLI command to view or edit configuration options
    # @since 0.6.2
    class Config < Command
      # @return [Symbol, nil] the key to view/edit, if any
      attr_accessor :key

      # @return [Array, nil] the list of values to set (or single value), if modifying
      attr_accessor :values

      # @return [Boolean] whether to reset the {#key}
      attr_accessor :reset

      # @return [Boolean] whether the value being set should be inside a list
      attr_accessor :as_list

      # @return [Boolean] whether to append values to existing key
      attr_accessor :append

      def initialize
        super
        self.key = nil
        self.values = []
        self.reset = false
        self.append = false
        self.as_list = false
      end

      def description
        'Views or edits current global configuration'
      end

      def run(*args)
        optparse(*args)
        if key
          if reset || values.size > 0
            modify_item
          else
            view_item
          end
        else
          list_configuration
        end
      end

      private

      def modify_item
        if reset
          log.debug "Resetting #{key}"
          YARD::Config.options[key] = YARD::Config::DEFAULT_CONFIG_OPTIONS[key]
        else
          log.debug "Setting #{key} to #{values.inspect}"
          items, current_items = encode_values, YARD::Config.options[key]
          items = [current_items].flatten + [items].flatten if append
          YARD::Config.options[key] = items
        end
        YARD::Config.save
      end

      def view_item
        log.debug "Viewing #{key}"
        puts YARD::Config.options[key].inspect
      end

      def list_configuration
        log.debug "Listing configuration"
        require 'yaml'
        puts YAML.dump(YARD::Config.options).sub(/\A--.*\n/, '').gsub(/\n\n/, "\n")
      end

      def encode_values
        if values.size == 1 && !as_list
          encode_value(values.first)
        else
          values.map {|v| encode_value(v) }
        end
      end

      def encode_value(value)
        case value
        when /^-?\d+/; value.to_i
        when "true"; true
        when "false"; false
        else value
        end
      end

      def optparse(*args)
        list = false
        self.as_list = false
        self.append = false
        opts = OptionParser.new
        opts.banner = "Usage: yard config [options] [item [value ...]]"
        opts.separator ""
        opts.separator "Example: yard config load_plugins true"
        opts.separator ""
        opts.separator "Views and sets configuration items. If an item is provided"
        opts.separator "With no value, the item is viewed. If a value is provided,"
        opts.separator "the item is modified. Specifying no item is equivalent to --list."
        opts.separator "If you specify multiple space delimited values, these are"
        opts.separator "parsed as an array of values."
        opts.separator ""
        opts.separator "Note that `true` and `false` are reserved words."
        opts.separator ""
        opts.separator "General options:"

        opts.on('-l', '--list', 'List current configuration') do
          list = true
        end
        opts.on('-r', '--reset', 'Resets the specific item to default') do
          self.reset = true
        end

        opts.separator ""
        opts.separator "Modifying keys:"

        opts.on('-a', '--append', 'Appends items to existing key values') do
          self.append = true
        end
        opts.on('--as-list', 'Forces the value(s) to be wrapped in an array') do
          self.as_list = true
        end

        common_options(opts)
        parse_options(opts, args)
        args = [] if list
        self.key = args.shift.to_sym if args.size >= 1
        self.values = args if args.size >= 1
        args
      end

    end
  end
end