#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



module Diaspora
  module Webhooks
    def self.included(klass)
      klass.class_eval do

        def to_diaspora_xml
          xml = "<XML>"
          xml += "<post>#{self.to_xml.to_s}</post>"
          xml += "</XML>"
        end

       end
    end
  end
end
