module I18n
  def self.just_raise_that_exception(*args)
    raise args.first
  end
end

I18n.exception_handler = :just_raise_that_exception
module ActionView
  module Helpers
    module TranslationHelper
      def translate(key, options = {})
        translation = I18n.translate(scope_key_by_partial(key), options.merge!(:raise => true))
        if html_safe_translation_key?(key) && translation.respond_to?(:html_safe)
          translation.html_safe
        else
          translation
        end
      end
      alias :t :translate
    end
  end
end
