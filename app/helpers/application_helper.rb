#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


module ApplicationHelper
  def current_aspect?(aspect)
    !@aspect.is_a?(Symbol) && @aspect.id == aspect.id
  end

  def object_path(object, opts = {})
    object = object.person if object.is_a? User
    eval("#{object.class.to_s.underscore}_path(object, opts)")
  end

  def object_fields(object)
    object.attributes.keys
  end

  def mine?(post)
    current_user.owns? post
  end

  def type_partial(post)
    class_name = post.class.name.to_s.underscore
    "#{class_name.pluralize}/#{class_name}"
  end

  def how_long_ago(obj)
    "#{time_ago_in_words(obj.created_at)} ago"
  end

  def person_url(person)
    case person.class.to_s
    when "User"
      user_path(person)
    when "Person"
      person_path(person)
    else
      I18n.t('application.helper.unknown_person')
    end
  end

  def owner_image_tag
    person_image_tag(current_user.person)
  end

  def owner_image_link
    person_image_link(current_user.person)
  end

  def person_image_tag(person)
    image_location = person.profile.image_url
    image_location ||= "/images/user/default.jpg"

    image_tag image_location, :class => "avatar", :alt => person.real_name, :title => person.real_name
  end

  def person_image_link(person)
    if current_user.friends.include?(person) || current_user.person == person
      link_to person_image_tag(person), object_path(person)
    else
      person_image_tag person
    end
  end

  def new_request(request_count)
    I18n.t('application.helper.new_requests') if request_count > 0
  end

  def post_yield_tag(post)
    (':' + post.id.to_s).to_sym
  end
end
