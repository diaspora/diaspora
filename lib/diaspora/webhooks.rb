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
