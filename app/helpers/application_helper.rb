module ApplicationHelper
  def object_path(object)
    eval("#{object.class.to_s.underscore}_path(object)")
  end

  def object_fields(object)
    object.attributes.keys 
  end

  def parse_sender_id_from_xml(xml)
    doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
    doc.xpath("/XML/head/sender/email").text.to_s
  end
  
  def parse_sender_object_from_xml(xml)
    sender_id = parse_sender_id_from_xml(xml)
    Person.where(:email => sender_id).first
  end

  def parse_body_contents_from_xml(xml)
    doc = Nokogiri::XML(xml) { |cfg| cfg.noblanks }
    doc.xpath("/XML/posts/post")
  end

  def parse_posts_from_xml(xml)
    posts = []
    body = parse_body_contents_from_xml(xml)
    body.children.each do |post|
      begin
        object = post.name.camelize.constantize.from_xml post.to_s
        posts << object if object.is_a? Post
      rescue
        puts "Not a real type: #{post.to_s}"
      end
    end
    posts
  end

  def store_posts_from_xml(xml)
    sender_object = parse_sender_object_from_xml(xml)
    posts = parse_posts_from_xml(xml)

    posts.each do |p|
      p.person = sender_object
      p.save
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
