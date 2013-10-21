
module Diaspora::Backbone
  module ParamHelpers

    class ParamsHash
      def initialize(hash)
        @_hash = stringify_keys(hash)
      end

      def require(key)
        key = key.to_s
        return ParamsHash.new(@_hash[key]) if @_hash.has_key?(key)
        raise ParamMissing
      end

      def permit(*filters)
        params = {}
        filters.each do |f|
          case f
          when Symbol, String
            permit_scalar(params, f)
          when Hash then
            permit_hash(params, stringify_keys(f))
          end
        end

        # these keys already exist as symbols in the respective `#permit` calls,
        # so there is no symbol leakage to be expected here
        symbolize_keys(params)
      end

      private

      def permit_scalar(params, key)
        key = key.to_s
        params[key] = @_hash[key] if @_hash.has_key?(key)
      end

      def permit_hash(params, filter)
        @_hash.select { |k, v| filter.keys.include?(k) }.each_pair do |k ,v|
          params[k] = ParamsHash.new(v).permit(filter[k])
        end
      end

      # taken from Rails ActiveSupport Hash core_ext
      def transform_keys(hash)
        result = {}
        hash.each_key do |k|
          result[yield(k)] = hash[k]
        end
        result
      end

      def stringify_keys(hash)
        transform_keys(hash) { |k| k.to_s }
      end

      def symbolize_keys(hash)
        transform_keys(hash) { |k| k.to_sym rescue k }
      end

      class ParamMissing < IndexError
      end
    end

    module Helpers
      def protected_params
        ParamsHash.new(params)
      end
    end

    def self.registered(app)
      app.helpers ParamHelpers::Helpers
    end
  end
end
