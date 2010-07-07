module SocketHelper
  
  def obj_id(object)
    object.is_a? Post ? object.id : object.post_id
  end
  
  
  def action_hash(object)
    begin
      v = render_to_string(type_partial(object), :post => object) unless object.is_a? Retraction

    rescue Exception => e
      puts "in failzord " + v.inspect
      puts object.inspect
      puts e.message
      raise e 
    end

    {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}
  end
  
end