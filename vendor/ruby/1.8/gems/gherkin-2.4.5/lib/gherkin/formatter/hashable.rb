module Gherkin
  module Formatter
    class Hashable
      def to_hash
        instance_variables.inject({}) do |hash, ivar|
          value = instance_variable_get(ivar)
          value = value.to_hash if value.respond_to?(:to_hash)
          if Array === value
            value = value.map do |e|
              e.respond_to?(:to_hash) ? e.to_hash : e
            end
          end
          hash[ivar[1..-1]] = value unless [[], nil].index(value)
          hash
        end
      end
    end
  end
end