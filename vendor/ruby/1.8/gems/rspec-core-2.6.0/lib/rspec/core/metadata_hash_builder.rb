module RSpec
  module Core
    module MetadataHashBuilder
      module Common
        def build_metadata_hash_from(args)
          metadata = args.last.is_a?(Hash) ? args.pop : {}

          if RSpec.configuration.treat_symbols_as_metadata_keys_with_true_values?
            add_symbols_to_hash(metadata, args)
          else
            warn_about_symbol_usage(args)
          end

          metadata
        end

        private

          def add_symbols_to_hash(hash, args)
            while args.last.is_a?(Symbol)
              hash[args.pop] = true
            end
          end

          def warn_about_symbol_usage(args)
            symbols = args.select { |a| a.is_a?(Symbol) }
            return if symbols.empty?
            Kernel.warn symbol_metadata_warning(symbols)
          end
      end

      module WithConfigWarning
        include Common

        private

          def symbol_metadata_warning(symbols)
            <<-NOTICE

*****************************************************************
WARNING: You have passed symbols (#{symbols.inspect}) as metadata
arguments to a configuration option.

In RSpec 3, these symbols will be treated as metadata keys with
a value of `true`.  To get this behavior now (and prevent this
warning), you can set a configuration option:

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

Note that this config setting should go before your other config
settings so that they can use symbols as metadata.
*****************************************************************

NOTICE
          end
      end

      module WithDeprecationWarning
        include Common

        private

          def symbol_metadata_warning(symbols)
            <<-NOTICE

*****************************************************************
DEPRECATION WARNING: you are using deprecated behaviour that will
be removed from RSpec 3.

You have passed symbols (#{symbols.inspect}) as additional
arguments for a doc string.

In RSpec 3, these symbols will be treated as metadata keys with
a value of `true`.  To get this behavior now (and prevent this
warning), you can set a configuration option:

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

Alternately, if your intention is to use the symbol as part of the
doc string (i.e. to specify a method name), you can change it to
a string such as "#method_name" to remove this warning.
*****************************************************************

NOTICE
          end
        end
      end
  end
end
