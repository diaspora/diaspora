#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



module Diaspora
  module Parser
    def self.owner_id_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      id = doc.xpath("//person_id").text.to_s
      Person.first(:id => id)
    end

    def self.parse_or_find_person_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      person_xml = doc.xpath("//person").to_s
      person_id = doc.xpath("//person/_id").text.to_s
      person = Person.first(:_id => person_id)
      person ? person : Person.from_xml( person_xml)
    end

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
