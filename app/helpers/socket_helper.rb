module SocketHelper
 include ApplicationHelper 
  def obj_id(object)
    (object.is_a? Post) ? object.id : object.post_id
  end
  
  def url_options
    {:host => "", :only_path => true}
  end

  def action_hash(object)
      
    begin
      v = render_to_string(:partial => type_partial(object), :locals => {:post => object}) unless object.is_a? Retraction


    rescue Exception => e
      puts "web socket view rendering failed for some reason." + v.inspect
      puts object.inspect
      puts e.message
      raise e 
    end

    {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}.to_json
  end

  

end
