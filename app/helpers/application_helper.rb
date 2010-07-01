module ApplicationHelper
  require 'lib/common'
  include Diaspora::XMLParser
  def object_path(object)
    eval("#{object.class.to_s.underscore}_path(object)")
  end

  def object_fields(object)
    object.attributes.keys 
  end

  def mine?(post)
    post.person == User.first
  end
  
  def type_partial(post)
    class_name = post.class.name.to_s.underscore
    "#{class_name.pluralize}/#{class_name}"
  end
  
  def how_long_ago(obj)
    time_ago_in_words(obj.created_at) + " ago."
  end

  def person_url(person)
    case person.class.to_s
    when "Friend"
      friend_path(person)
    when "User"
      user_path(person)
    else
      "unknown person"
    end
  end

  def link_to_person(person)
    link_to person.real_name, person_url(person)
  end

  def owner_picture
    default = "#{root_url}images/user/default.jpg"
    image = "#{root_url}images/user/#{User.first.profile.last_name.gsub(/ /,'').downcase}.jpg"

    if File.exist?("public/images/user/#{User.first.profile.last_name.gsub(/ /,'').downcase}.jpg")
      image_tag image, :id => "user_picture"
    else
      image_tag default, :id => "user_picture"
    end
  end

end
