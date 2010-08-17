module SocketsHelper
 include ApplicationHelper 
  
 def obj_id(object)
    (object.is_a? Post) ? object.id : object.post_id
  end

  def action_hash(uid, object)
    begin
      user = User.find_by_id(uid)
      v = render_to_string(:partial => type_partial(object), :locals => {:post => object, :current_user => user}) unless object.is_a? Retraction
    rescue Exception => e
      Rails.logger.error("web socket view rendering failed for object #{object.inspect}.")
      raise e 
    end
    action_hash = {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}
    
    if object.is_a? Photo
      action_hash[:photo_hash] = object.thumb_hash
    elsif object.is_a? StatusMessage
      action_hash[:status_message_hash] = object.latest_hash
      action_hash[:status_message_hash][:mine?] = true if object.person.owner_id == uid
    end
    
    action_hash.to_json
  end

  

end
