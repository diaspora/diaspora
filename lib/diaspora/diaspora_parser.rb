module Diaspora
  module DiasporaParser
    def parse_owner_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      email = doc.xpath("//person/email").text.to_s
      Person.where(:email => email).first
    end

    def parse_body_contents_from_xml(xml)
      doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
      doc.xpath("/XML/posts/post")
    end

    def parse_objects_from_xml(xml)
      objects = []
      body = parse_body_contents_from_xml(xml)
      body.children.each do |post|
        begin
          object = post.name.camelize.constantize.from_xml post.to_s
          object.person =  parse_owner_from_xml post.to_s if object.respond_to? :person  
          objects << object 
        rescue
          Rails.logger.info "Not a real type: #{object.to_s}"
        end
      end
      objects
    end

    def store_objects_from_xml(xml)
      objects = parse_objects_from_xml(xml)
      objects.each do |p|
        Rails.logger.info("Receiving object:\n#{p.inspect}")
        if p.is_a? Retraction
          p.perform
        elsif p.is_a? Request
          User.owner.receive_friend_request(p)
        #This line checks if the sender was in the database, among other things?
        elsif p.respond_to?(:person) && !(p.person.nil?) && !(p.person.is_a? User) #WTF
          Rails.logger.info("Saving object with success: #{p.save}")
        end
        #p.save if p.respond_to?(:person) && !(p.person == nil) #WTF
      end
    end
  end
end