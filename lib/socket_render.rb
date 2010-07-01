module SocketRenderer
 require 'app/helpers/application_helper' 
  def self.instantiate_view
    @view = ActionView::Base.new(ActionController::Base.view_paths, {})  
    class << @view  
      include ApplicationHelper 
      include Rails.application.routes.url_helpers
      include ActionController::RequestForgeryProtection::ClassMethods
      def protect_against_forgery?
        false
      end
    end
  end

  def self.view_hash(object)
    begin
      v = view_for(object)

    rescue Exception => e
      puts "in failzord " + v.inspect
      puts object.inspect
      puts e.message
      raise e 
    end

    {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}
  end

  def self.view_for(object)
    puts object.inspect
    puts @view.type_partial(object)
    
    @view.render @view.type_partial(object), :post  => object
  end

  def self.obj_id(object)
    if object.is_a? Post
      object.id
    else 
      object.post.id
    end
  end
end
