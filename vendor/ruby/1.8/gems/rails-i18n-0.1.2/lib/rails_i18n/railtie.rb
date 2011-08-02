require 'rails'

module RailsI18n
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'rails-i18n' do |app|
      I18n.load_path << Dir[File.join(File.expand_path(File.dirname(__FILE__) + '/../../rails/locale'), '*.{rb,yml}')]
      I18n.load_path.flatten!
    end
  end
end
