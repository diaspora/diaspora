#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora
  module Parser
    def self.from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      return unless body = doc.xpath("/XML/post").children.first

      begin
        new_object = body.name.camelize.constantize.from_xml body.to_s

        if new_object.is_a? Post
          existing_object = new_object.class.find_by_id(new_object.id)
          existing_object ? (return existing_object) : (return new_object)
        end

        new_object

      rescue NameError => e
        if e.message.include? 'wrong constant name'
          Rails.logger.info "Not a real type: #{object.to_s}"
        end
        raise e
      end
    end
  end
end
