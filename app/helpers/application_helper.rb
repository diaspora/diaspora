module ApplicationHelper
  def object_path(object)
    eval("#{object.class.to_s.underscore}_path(object)")
  end

  def object_fields(object)
    object.attributes.keys 
  end

  def mine?(post)
    post.person.id == current_user.person.id
  end
  
  def type_partial(post)
    class_name = post.class.name.to_s.underscore
    "#{class_name.pluralize}/#{class_name}"
  end
  
  def how_long_ago(obj)
    "#{time_ago_in_words(obj.created_at)} ago."
  end

  def person_url(person)
    case person.class.to_s
    when "User"
      user_path(person)
    when "Person"
      person_path(person)
    else
      "unknown person"
    end
  end

  def link_to_person(person)
    link_to person.real_name, person_path(person)
  end

  def owner_image_tag
    person_image_tag(User.owner)
  end

  def person_image_tag(person)
    image_location = person.profile.image_url
    image_location ||= "/images/user/default.jpg"

    image_tag image_location, :class => "person_picture", :alt => person.real_name, :title => person.real_name
  end

  def person_image_link(person)
    link_to person_image_tag(person), object_path(person)
  end

  def owner_image_link
    person_image_link(User.owner)
  end

  def new_request(request_count)
    "new_requests" if request_count > 0
  end
  
  def post_yield_tag(post)
    (':' + post.id.to_s).to_sym
  end

end
