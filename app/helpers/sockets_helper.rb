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


module SocketsHelper
 include ApplicationHelper 
  
 def obj_id(object)
    (object.is_a? Post) ? object.id : object.post_id
  end

  def action_hash(uid, object, opts={})
    begin
      user = User.find_by_id uid
      v = render_to_string(:partial => type_partial(object), :locals => {:post => object, :current_user => user}) unless object.is_a? Retraction
    rescue Exception => e
      Rails.logger.error("web socket view rendering failed for object #{object.inspect}.")
      raise e 
    end
    action_hash = {:class =>object.class.to_s.underscore.pluralize,  :html => v, :post_id => obj_id(object)}
    action_hash.merge! opts 
    if object.is_a? Photo
      action_hash[:photo_hash] = object.thumb_hash
    elsif object.is_a? StatusMessage
      action_hash[:status_message_hash] = object.latest_hash
      action_hash[:status_message_hash][:mine?] = true if object.person.owner_id == uid
    end

    if object.person.owner_id == uid
      action_hash[:mine?] = true
    end

    action_hash.to_json
  end

  

end
