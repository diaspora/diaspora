# encoding: utf-8

require 'i18n-inflector'
require 'i18n-inflector-rails/version'
require 'i18n-inflector-rails/errors'
require 'i18n-inflector-rails/options'
require 'i18n-inflector-rails/inflector'

if defined? Rails::Engine

  require 'i18n-inflector-rails/railtie'

else

  if not defined? ActionController::Base
    require 'active_support/core_ext/module/deprecation' # workaround for Rails missing require
    require 'action_controller'
  end
  require 'action_view'       if not defined? ActionView::Base

  ActionController::Base.send(:extend,  I18n::Inflector::Rails::ClassMethods)
  ActionController::Base.send(:include, I18n::Inflector::Rails::InstanceMethods)
  ActionController::Base.send(:include, I18n::Inflector::Rails::InflectedTranslate)

  if ActionController::Base.respond_to?(:helper_method)
    ActionController::Base.helper_method :translate
  end

end
