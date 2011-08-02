require 'test/unit'
require 'test_declarative'
require 'i18n-inflector'

class Test::Unit::TestCase
  def teardown
    I18n.locale             = nil
    I18n.default_locale     = :en
    I18n.load_path          = []
    I18n.available_locales  = nil
    I18n.backend            = nil
  end if not method_defined?(:teardown)

  def translations
    I18n.backend.instance_variable_get(:@translations)
  end

  def store_translations(*args)
    data   = args.pop
    locale = args.pop || :en
    I18n.backend.store_translations(locale, data)
  end

end

Object.class_eval do
  def meta_class
    class << self; self; end
  end
end unless Object.method_defined?(:meta_class)
