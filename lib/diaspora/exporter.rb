#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Diaspora

  class Exporter
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
  end

  module Exporters
    module XML
      def execute(user)
        builder = Nokogiri::XML::Builder.new do |xml|
          user_person_id = user.person.id
          xml.export {
            xml.user {
              xml.username user.username
              xml.serialized_private_key user.serialized_private_key 
              
              xml.parent << user.person.to_xml
            }
            xml.aspects {
              user.aspects.each do |aspect|
                xml.aspect { 
                  xml.name aspect.name
                   
                  xml.person_ids {
                    aspect.person_ids.each do |id|
                      xml.person_id id
                    end
                  }

                  xml.post_ids {
                    aspect.posts.find_all_by_person_id(user_person_id).each do |post|
                      xml.post_id post.id
                    end
                  }
                }
              end
            }

            xml.people {
              user.friends.each do |friend|
                xml.parent << friend.to_xml
              end
            }

            xml.posts {
              user.raw_visible_posts.find_all_by_person_id(user_person_id).each do |post|
                #post_doc = post.to_xml
                
                #post.comments.each do |comment|
                #  post_doc << comment.to_xml
                #end

                xml.parent << post.to_xml
              end
            }
          }
        end

        # This is a hack.  Nokogiri interprets *.to_xml as a string.
        # we want to inject document objects, instead.  See lines: 25,35,40.
        # Solutions?
        CGI.unescapeHTML(builder.to_xml.to_s)
      end
    end
  end

end
