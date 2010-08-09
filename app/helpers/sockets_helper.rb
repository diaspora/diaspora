module SocketsHelper
 include ApplicationHelper 
  
 def obj_id(object)
    (object.is_a? Post) ? object.id : object.post_id
  end
  
  def url_options
    {:host => ""}
  end

  def action_hash(object)
    begin
      v = render_to_string(:partial => type_partial(object), :locals => {:post => object}) unless object.is_a? Retraction
    rescue Exception => e
      Rails.logger.error("web socket view rendering failed for object #{object.inspect}.")
      raise e 
    end
    action_hash = {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}
    
    if object.is_a? Photo
      action_hash[:photo_hash] = object.thumb_hash
    elsif object.is_a? StatusMessage
      action_hash[:status_message_hash] = object.latest_hash
    end
    
    action_hash.to_json
  end

  

end
