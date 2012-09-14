module I18n
  module Backend
    module InterpolationFallbacks
      def translate(locale, key, options = {})
        default = extract_non_symbol_default!(options) if options[:default]
        options.merge!(:default => default) if default

        I18n.fallbacks[locale].each do |fallback|
          begin
            result = super(fallback, key, options)
            return result unless result.nil?
          rescue I18n::MissingInterpolationArgument
          end
        end

        return super(locale, nil, options) if default
        raise(I18n::MissingInterpolationArgument.new(options, "key: #{key} in locale: #{locale}"))
      end
    end
  end
end
