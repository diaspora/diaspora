#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post < ActiveRecord::Base
  require File.join(Rails.root, 'lib/encryptable')
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Guid

  xml_attr :diaspora_handle
  xml_attr :public
  xml_attr :created_at

  has_many :comments, :order => 'created_at ASC'
  has_many :post_visibilities
  has_many :aspects, :through => :post_visibilities
  belongs_to :person

  cattr_reader :per_page
  @@per_page = 10

  before_destroy :propogate_retraction
  after_destroy :destroy_comments

  attr_accessible :user_refs

  def self.diaspora_initialize params
    new_post = self.new params.to_hash
    new_post.person = params[:person]
    params[:aspect_ids].each do |aspect_id|
      new_post.aspects << Aspect.find_by_id(aspect_id)
    end if params[:aspect_ids]
    new_post.public = params[:public] if params[:public]
    new_post.pending = params[:pending] if params[:pending]
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

  def decrement_user_refs
    user_refs -= 1
    if (user_refs > 0) || person.owner.nil? == false
      save
    else
      destroy
    end
  end

  protected
  def destroy_comments
    comments.each { |c| c.destroy }
  end

  def propogate_retraction
    self.person.owner.retract(self)
  end
end

