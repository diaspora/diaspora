#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Guid

  xml_attr :diaspora_handle
  xml_attr :public
  xml_attr :created_at

  has_many :comments, :order => 'created_at ASC'
  has_many :likes, :conditions => '`likes`.`positive` = 1'
  has_many :dislikes, :conditions => '`likes`.`positive` = 0', :class_name => 'Like'
  has_many :post_visibilities
  has_many :aspects, :through => :post_visibilities
  has_many :mentions, :dependent => :destroy
  belongs_to :author, :class_name => 'Person'

  cattr_reader :per_page
  @@per_page = 10

  def user_refs
    self.post_visibilities.count
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

  def as_json(opts={})
    {
        :post => {
            :id     => self.guid,
            :author => self.author.as_json,
        }
    }
  end

  def mutable?
    false
  end

  def subscribers(user)
    user.people_in_aspects(user.aspects_with_post(self.id))
  end

  def receive(user, person)
    #exists locally, but you dont know about it
    #does not exsist locally, and you dont know about it
    #exists_locally?
    #you know about it, and it is mutable
    #you know about it, and it is not mutable

    local_post = Post.where(:guid => self.guid).first
    if local_post && local_post.author_id == self.author_id
      known_post = user.visible_posts(:guid => self.guid).first
      if known_post
        if known_post.mutable?
          known_post.update_attributes(self.attributes)
        else
          Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason=immutable existing_post=#{known_post.id}")
        end
      else
        user.add_post_to_aspects(local_post)
        user.notify_if_mentioned(local_post)
        Rails.logger.info("event=receive payload_type=#{self.class} update=true status=complete sender=#{self.diaspora_handle} existing_post=#{local_post.id}")
        return local_post
      end
    elsif !local_post
      self.save
      user.add_post_to_aspects(self)
      user.notify_if_mentioned(self)
      Rails.logger.info("event=receive payload_type=#{self.class} update=false status=complete sender=#{self.diaspora_handle}")
      return self
    else
      Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason='update not from post owner' existing_post=#{self.id}")
    end
  end
end

