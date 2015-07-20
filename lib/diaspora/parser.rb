#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Parser
    def self.from_xml(xml)
      doc = Nokogiri::XML(xml) {|cfg| cfg.noblanks }
      return unless body = doc.xpath("/XML/post").children.first
      class_name = body.name.gsub("-", "/")
      ::Logging::Logger["XMLLogger"].debug "from_xml: #{body}"
      begin
        class_name.camelize.constantize.from_xml body.to_s
      rescue NameError => e
        # A pods is trying to federate an object we don't recognize.
        # i.e. their codebase is different from ours.
        ::Logging::Logger[self].warn("Error while parsing the xml: #{e.message}")
        nil
      end
    end
  end
end
