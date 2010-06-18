module ApplicationHelper
  def object_path(object)
    eval("#{object.class.to_s.underscore}_path(object)")
  end

  def object_fields(object)
    object.attributes.keys 
  end

  def store_posts_from_xml(xml)
    doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
    doc.xpath("//post").each do |post| #this is the post wrapper
      post.children.each do|type|  #now the text of post itself is the type 
        #type object to xml is the the thing we want to from_xml
        object =  type.name.camelize.constantize.from_xml type.to_s
        object.save
      end
    end
  end
end
