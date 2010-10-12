#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora

  class Importer
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
  end

  module Importers
    module XML
      def execute(xml)
        doc = Nokogiri::XML.parse(xml)
        user, person = parse_user(doc)
        user
        


      end

      def parse_user(doc)
        user = User.new
        user_doc = doc.xpath('/export/user')
        user.username = user_doc.xpath('//user/username').text
        user.serialized_private_key=  user_doc.xpath('//user/serialized_private_key').text
        person = Person.from_xml(user_doc.xpath('//user/person').to_s)
        [user, person]
      end

      def parse_aspects(doc)
        aspects = []
        aspect_doc = doc.xpath('/export/aspects/aspect')

        aspect_doc.each do |x| 
          
          puts x.to_s
          puts; puts
          
          
          aspect = Aspect.new

          aspect.id = x.xpath('//aspect/_id').text
          aspect.name = x.xpath('//aspect/name').text

          aspect.post_ids = x.xpath('//aspect/post_ids/post_id').collect(&:text)
          aspects << aspect
        end
        
        aspects

      end

      def parse_people(doc)
      end


      def parse_posts(doc)
      end

    end
  end

end
