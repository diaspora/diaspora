#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module SocketsHelper
  include ApplicationHelper
  include NotificationsHelper

  def obj_id(object)
    object.respond_to?(:post_id) ? object.post_id : object.id
  end

  def action_hash(uid, object, opts={})
    begin
      user = User.find_by_id uid
      unless user.nil?
        old_locale = I18n.locale
        I18n.locale = user.language.to_s
      end

      if object.is_a? StatusMessage
        post_hash = {:post => object,
          :person => object.person,
          :photos => object.photos,
          :comments => object.comments.map{|c|
            {:comment => c,
             :person => c.person
            }
        },
          :current_user => user,
          :aspects => user.aspects,
        }
        v = render_to_string(:partial => 'shared/stream_element', :locals => post_hash)
      elsif object.is_a? Person
        person_hash = {
          :single_aspect_form => opts["single_aspect_form"],
          :person => object,
          :aspects => user.aspects,
          :contact => user.contact_for(object),
          :request => user.request_for(object),
          :current_user => user}
        v = render_to_string(:partial => 'people/person', :locals => person_hash)

      elsif object.is_a? Comment
        v = render_to_string(:partial => 'comments/comment', :locals => {:hash => {:comment => object, :person => object.person}})

      elsif object.is_a? Notification
        v = render_to_string(:partial => 'notifications/popup', :locals => {:note => object, :person => object.person})

      else
        v = render_to_string(:partial => type_partial(object), :locals => {:post => object, :current_user => user}) unless object.is_a? Retraction
      end
    rescue Exception => e
      Rails.logger.error("event=socket_render status=fail user=#{user.diaspora_handle} object=#{object.id.to_s}")
      raise e.original_exception
    end
    action_hash = {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}
    action_hash.merge! opts
    if object.is_a? Photo
      action_hash[:photo_hash] = object.thumb_hash
    end

    if object.is_a? Comment
      post = object.post
      action_hash[:comment_id] = object.id
      action_hash[:my_post?] = (post.person.owner.id == uid)
      action_hash[:post_guid] = post.id

    end

    action_hash[:mine?] = object.person && (object.person.owner.id == uid) if object.respond_to?(:person)

    I18n.locale = old_locale unless user.nil?

    action_hash.to_json
  end
end
