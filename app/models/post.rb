#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post
  require File.join(Rails.root, 'lib/encryptable')
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include MongoMapper::Document
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks

  xml_reader :_id
  xml_reader :diaspora_handle
  xml_reader :public
  xml_reader :created_at


  key :public, Boolean, :default => false

  key :diaspora_handle, String
  key :user_refs, Integer, :default => 0
  key :pending, Boolean, :default => false
  key :aspect_ids, Array, :typecast => 'ObjectId'

  many :comments, :class_name => 'Comment', :foreign_key => :post_id, :order => 'created_at ASC'
  many :aspects, :in => :aspect_ids, :class_name => 'Aspect'
  belongs_to :person, :class_name => 'Person'

  timestamps!

  cattr_reader :per_page
  @@per_page = 10

  before_destroy :propogate_retraction
  after_destroy :destroy_comments

  attr_accessible :user_refs
  
  def self.instantiate params
    new_post = self.new params.to_hash
    new_post.person = params[:person]
    new_post.aspect_ids = params[:aspect_ids]
    new_post.public = params[:public]
    new_post.pending = params[:pending]
    new_post.diaspora_handle = new_post.person.diaspora_handle
    new_post
  end

  def as_json(opts={})
    {
      :post => {
        :id     => self.id,
        :person => self.person.as_json,
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
    
    on_pod = Post.find_by_id(self.id)

    if on_pod && on_pod.diaspora_handle == self.diaspora_handle 
      known_post = user.find_visible_post_by_id(self.id)
      if known_post 
        if known_post.mutable?
          known_post.update_attributes(self.to_mongo)
        else
          Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason=immutable existing_post=#{known_post.id}")
        end
      elsif on_pod == self 
        user.update_user_refs_and_add_to_aspects(on_pod)
        Rails.logger.info("event=receive payload_type=#{self.class} update=true status=complete sender=#{self.diaspora_handle} existing_post=#{on_pod.id}")
        self 
      end
    elsif !on_pod 
      user.update_user_refs_and_add_to_aspects(self)
      Rails.logger.info("event=receive payload_type=#{self.class} update=false status=complete sender=#{self.diaspora_handle}")
      self 
    else
      Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.diaspora_handle} reason='update not from post owner' existing_post=#{self.id}")
    end
  end

  protected
  def destroy_comments
    comments.each{|c| c.destroy}
  end

  def propogate_retraction
    self.person.owner.retract(self)
  end
end

