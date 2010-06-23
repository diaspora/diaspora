module ApplicationHelper
  def object_path(object)
    eval("#{object.class.to_s.underscore}_path(object)")
  end

  def object_fields(object)
    object.attributes.keys 
  end

  def store_posts_from_xml(xml)
    doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }

    #i need to check some sort of metadata field

    doc.xpath("/XML/posts/post").each do |post| #this is the post wrapper
      post.children.each do|type|  #now the text of post itself is the type 
        #type object to xml is the the thing we want to from_xml
        check_and_save_post(type)
      end
    end
  end

  def check_and_save_post(type)
    begin
      object = type.name.camelize.constantize.from_xml type.to_s
      object.save if object.is_a? Post
    rescue
      puts "Not of type post"
    end
  end

  def mine?(post)
    post.owner == User.first.email
  end
  
  def type_partial(post)
    class_name = post.class.name.to_s.underscore
    "#{class_name.pluralize}/#{class_name}"
  end
  
  def how_long_ago(obj)
    time_ago_in_words(obj.created_at) + " ago."
  end
end
