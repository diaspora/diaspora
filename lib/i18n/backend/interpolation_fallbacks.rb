# frozen_string_literal: true

module I18n
  module Backend
    module InterpolationFallbacks
      def translate(locale, key, options = {})
        default = extract_non_symbol_default!(options) if options[:default]
        options.merge!(:default => default) if default

        original_exception = nil

        I18n.fallbacks[locale].each do |fallback|
          begin
            result = super(fallback, key, options)
            return result unless result.nil?
          rescue I18n::MissingInterpolationArgument, I18n::InvalidPluralizationData => e
            original_exception ||= e
          end
        end

        return super(locale, nil, options) if default
        raise original_exception
      end
    end
  end
end
