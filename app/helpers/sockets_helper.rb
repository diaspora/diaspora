#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module SocketsHelper
  include ApplicationHelper
  include NotificationsHelper

  def obj_id(object)
    if object.respond_to?(:post_id)
      object.post_id
    elsif object.respond_to?(:post_guid)
      object.post_guid
    else
      object.id
    end
  end

  def action_hash(user, object, opts={})
    uid = user.id
    begin
      unless user.nil?
        old_locale = I18n.locale
        I18n.locale = user.language.to_s
      end

      if object.is_a? StatusMessage
        post_hash = {:post => object,
          :author => object.author,
          :photos => object.photos,
          :comments => object.comments.map{|c|
            {:comment => c,
             :author => c.author
            }
        },
          :current_user => user,
          :all_aspects => user.aspects,
        }
        v = render_to_string(:partial => 'shared/stream_element', :locals => post_hash)
      elsif object.is_a? Person
        person_hash = {
          :single_aspect_form => opts["single_aspect_form"],
          :person => object,
          :all_aspects => user.aspects,
          :contact => user.contact_for(object),
          :request => user.request_from(object),
          :current_user => user}
        v = render_to_string(:partial => 'people/person', :locals => person_hash)

      elsif object.is_a? Comment
        v = render_to_string(:partial => 'comments/comment', :locals => {:comment => object, :person => object.author})

      elsif object.is_a? Like
        v = render_to_string(:partial => 'likes/likes', :locals => {:likes => object.post.likes, :dislikes => object.post.dislikes})

      elsif object.is_a? Notification
        v = render_to_string(:partial => 'notifications/popup', :locals => {:note => object, :person => opts[:actor]})

      else
        raise "#{object.inspect} with class #{object.class} is not actionhashable." unless object.is_a? Retraction
      end
    rescue Exception => e
      Rails.logger.error("event=socket_render status=fail user=#{user.diaspora_handle} object=#{object.id.to_s}")
      raise e
    end
    action_hash = {:class =>object.class.to_s.underscore.pluralize, :html => v, :post_id => obj_id(object)}
    action_hash.merge! opts
    if object.is_a? Photo
      action_hash[:photo_hash] = object.thumb_hash
    end

    if object.is_a? Comment
      post = object.post
      action_hash[:comment_id] = object.id
      action_hash[:my_post?] = (post.author.owner_id == uid)
      action_hash[:post_guid] = post.guid

    end

    if object.is_a? Like
      action_hash[:post_guid] = object.post.guid
    end

    action_hash[:mine?] = object.author && (object.author.owner_id == uid) if object.respond_to?(:author)

    I18n.locale = old_locale unless user.nil?

    action_hash.to_json
  end
end
