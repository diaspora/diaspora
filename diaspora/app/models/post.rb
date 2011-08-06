#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Guid

  include Diaspora::Likeable

  xml_attr :diaspora_handle
  xml_attr :public
  xml_attr :created_at

  has_many :comments, :dependent => :destroy

  has_many :aspect_visibilities
  has_many :aspects, :through => :aspect_visibilities

  has_many :post_visibilities
  has_many :contacts, :through => :post_visibilities
  has_many :mentions, :dependent => :destroy

  has_many :reshares, :class_name => "Reshare", :foreign_key => :root_guid, :primary_key => :guid
  has_many :resharers, :class_name => 'Person', :through => :reshares, :source => :author

  belongs_to :author, :class_name => 'Person'

  def diaspora_handle
    read_attribute(:diaspora_handle) || self.author.diaspora_handle
  end

  def user_refs
    if AspectVisibility.exists?(:post_id => self.id)
      self.post_visibilities.count + 1
    else
      self.post_visibilities.count
    end
  end

  def diaspora_handle= nd
    self.author = Person.where(:diaspora_handle => nd).first
    write_attribute(:diaspora_handle, nd)
  end

  def self.diaspora_initialize params
    new_post = self.new params.to_hash
    new_post.author = params[:author]
    new_post.public = params[:public] if params[:public]
    new_post.pending = params[:pending] if params[:pending]
    new_post.diaspora_handle = new_post.author.diaspora_handle
    new_post
  end

  # @return Returns true if this Post will accept updates (i.e. updates to the caption of a photo).
  def mutable?
    false
  end

  # The list of people that should receive this Post.
  #
  # @param [User] user The context, or dispatching user.
  # @return [Array<Person>] The list of subscribers to this post
  def subscribers(user)
    if self.public?
      user.contact_people
    else
      user.people_in_aspects(user.aspects_with_post(self.id))
    end
  end

  # @param [User] user The user that is receiving this post.
  # @param [Person] person The person who dispatched this post to the
  # @return [void]
  def receive(user, person)
    #exists locally, but you dont know about it
    #does not exsist locally, and you dont know about it
    #exists_locally?
    #you know about it, and it is mutable
    #you know about it, and it is not mutable

    local_post = Post.where(:guid => self.guid).first
    if local_post && local_post.author_id == self.author_id
      known_post = user.visible_posts.where(:guid => self.guid).first
      if known_post
        if known_post.mutable?
          known_post.update_attributes(self.attributes)
        else
          Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason=immutable existing_post=#{known_post.id}")
        end
      else
        user.contact_for(person).receive_post(local_post)
        user.notify_if_mentioned(local_post)
        Rails.logger.info("event=receive payload_type=#{self.class} update=true status=complete sender=#{self.diaspora_handle} existing_post=#{local_post.id}")
        return local_post
      end
    elsif !local_post
      if self.save
        user.contact_for(person).receive_post(self)
        user.notify_if_mentioned(self)
        Rails.logger.info("event=receive payload_type=#{self.class} update=false status=complete sender=#{self.diaspora_handle}")
        return self
      else
        Rails.logger.info("event=receive payload_type=#{self.class} update=false status=abort sender=#{self.diaspora_handle} reason=#{self.errors.full_messages}")
      end
    else
      Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason='update not from post owner' existing_post=#{self.id}")
    end
  end

  def activity_streams?
    false
  end

  # @return [Array<Comment>]
  def last_three_comments
    self.comments.order('created_at DESC').limit(3).includes(:author => :profile).reverse
  end
end

