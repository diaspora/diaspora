#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Parser
    def self.from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      return unless body = doc.xpath("/XML/post").children.first
      class_name = body.name.gsub('-', '/')
      class_name.camelize.constantize.from_xml body.to_s
    end
  end
end
