#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Post
  require File.join(Rails.root, 'lib/encryptable')
  require File.join(Rails.root, 'lib/diaspora/websocket')
  include MongoMapper::Document
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Socketable

  xml_reader :_id
  xml_reader :diaspora_handle
  xml_reader :public
  xml_reader :created_at

  key :public, Boolean, :default => false

  key :diaspora_handle, String
  key :user_refs, Integer, :default => 0

  many :comments, :class_name => 'Comment', :foreign_key => :post_id, :order => 'created_at ASC'
  belongs_to :person, :class_name => 'Person'

  timestamps!

  cattr_reader :per_page
  @@per_page = 10

  before_destroy :propogate_retraction
  after_destroy :destroy_comments

  def self.instantiate params
    new_post = self.new params.to_hash
    new_post.person = params[:person]
    new_post.public = params[:public]
    new_post.save
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

  protected
  def destroy_comments
    comments.each{|c| c.destroy}
  end

  def propogate_retraction
    self.person.owner.retract(self)
  end
end

