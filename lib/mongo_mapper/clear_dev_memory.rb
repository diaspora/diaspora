#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



module MongoMapper
  class ClearDevMemory
    def initialize(app)
      @app = app
    end

    def call(env)
      if Rails.configuration.cache_classes
      else
        MongoMapper::Document.descendants.each do |m|
          m.descendants.clear if m.respond_to? :descendants
        end
        MongoMapper::Document.descendants.clear
        MongoMapper::EmbeddedDocument.descendants.clear
      end
      @app.call(env)
    end
  end
end
