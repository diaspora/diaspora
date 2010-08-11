module Diaspora
  module Parser
    def self.owner_id_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      id = doc.xpath("//person_id").text.to_s
      Person.first(:id => id)
    end

    def self.get_or_create_person_object_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      person_xml = doc.xpath("//request/person").to_s
      person_id = doc.xpath("//request/person/_id").text.to_s
      person = Person.first(:_id => person_id)
      person ? person : Person.from_xml( person_xml)
    end

    def self.from_xml(xml)

      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      return unless body = doc.xpath("/XML/post").children.first

      begin
        body.name.camelize.constantize.from_xml body.to_s
      rescue NameError => e
        if e.message.include? 'wrong constant name'
          Rails.logger.info "Not a real type: #{object.to_s}"
        end
        raise e
      end
    end

  end
end
