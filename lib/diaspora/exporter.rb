#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

module Diaspora

  def self.bone(user)
    exporter = Diaspora::Exporter.new(Diaspora::Exporters::XML)
    exporter.execute(user)
  end

  class Exporter
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
  end

  module Exporters
    module XML
      def execute(user)
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.user {
            xml.username user.username
            xml.serialized_private_key user.serialized_private_key 
            xml.person user.person.to_xml

            xml.aspects {
              user.aspects.each do |aspect|
                xml.aspect { 
                  xml.id_ aspect.id
                  xml.name aspect.name
                
                  xml.people {
                    aspect.people.each do |person|
                      xml.person person.to_xml
                    end
                  }
                  xml.posts {
                    aspect.posts.each do |post|
                      xml.post post.to_xml if post.respond_to? :to_xml
                    end
                  }
                }
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
