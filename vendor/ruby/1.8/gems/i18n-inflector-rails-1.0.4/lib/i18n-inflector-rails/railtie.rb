# encoding: utf-8
#
# Author::    Paweł Wilk (mailto:pw@gnu.org)
# Copyright:: (c) 2011 by Paweł Wilk
# License::   This program is licensed under the terms of {file:LGPL-LICENSE GNU Lesser General Public License} or {file:COPYING Ruby License}.
# 
# This file loads I18n::Inflector::Rails goodies into Rails.

module I18n
  module Inflector
    module Rails

      class Railtie < ::Rails::Engine

        initializer :before_initialize do
          ActionController::Base.send(:extend,  I18n::Inflector::Rails::ClassMethods)
          ActionController::Base.send(:include, I18n::Inflector::Rails::InstanceMethods)
        end

        initializer :after_initialize do
          ActionController::Base.helper I18n::Inflector::Rails::InflectedTranslate
        end
      end

    end
  end
end
