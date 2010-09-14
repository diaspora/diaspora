#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


module ApplicationHelper
  
  def current_aspect?(aspect)
    !@aspect.is_a?(Symbol) && @aspect.id == aspect.id
  end
  
  def object_path(object, opts = {})
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

  def owner_image_tag
    person_image_tag(current_user)
  end

  def owner_image_link
    person_image_link(current_user)
  end

  def person_image_tag(person)
    image_location = person.profile.image_url
    image_location ||= "/images/user/default.jpg"

    image_tag image_location, :class => "avatar", :alt => person.real_name, :title => person.real_name
  end

  def person_image_link(person)
    link_to person_image_tag(person), object_path(person)
  end

  def new_request(request_count)
    "new_requests" if request_count > 0
  end
  
  def post_yield_tag(post)
    (':' + post.id.to_s).to_sym
  end

end
