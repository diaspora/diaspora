module Diaspora
  module Parser
    def parse_owner_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      email = doc.xpath("//person/email").text.to_s
      Person.first(:email => email)
    end

    def parse_body_contents_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      doc.xpath("/XML/posts/post")
    end
    
    def parse_owner_id_from_xml(doc)
      id = doc.xpath("//person_id").text.to_s
      Person.first(:id => id)
    end

    def parse_objects_from_xml(xml)
      objects = []
      body = parse_body_contents_from_xml(xml)
      body.children.each do |post|
        begin
          object = post.name.camelize.constantize.from_xml post.to_s
          if object.is_a? Retraction
          elsif object.is_a? Profile
            person = parse_owner_id_from_xml post
            person.profile = object
            person.save  
          elsif object.is_a? Request
            person_string = Nokogiri::XML(xml) { |cfg| cfg.noblanks }.xpath("/XML/posts/post/request/person").to_s
            person = Person.from_xml person_string
            person.serialized_key ||= object.exported_key
            object.person = person
            object.person.save

          elsif object.respond_to? :person  
            object.person =  parse_owner_from_xml post.to_s 
          end
          objects << object
        rescue NameError => e
          if e.message.include? 'wrong constant name'
            Rails.logger.info "Not a real type: #{object.to_s}"
          else
            raise e
          end
        end
      end
      objects
    end

    def store_objects_from_xml(xml, user)
      objects = parse_objects_from_xml(xml)
      objects.each do |p|
        Rails.logger.debug("Receiving object:\n#{p.inspect}")
        if p.is_a? Retraction
          Rails.logger.debug "Got a retraction for #{p.post_id}"
          p.perform
        elsif p.is_a? Request
          user.receive_friend_request(p)
        elsif p.is_a? Profile
          p.save
        elsif p.respond_to?(:person) && !(p.person.nil?) && !(p.person.is_a? User) 
          Rails.logger.debug("Saving object with success: #{p.save}")
        end
      end
    end
  end
end
