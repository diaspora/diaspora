#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class Post
  require 'lib/diaspora/websocket'
  require 'lib/encryptable'
  include MongoMapper::Document
  include ApplicationHelper
  include ROXML
  include Diaspora::Webhooks
  include Diaspora::Socketable

  xml_accessor :_id
  xml_accessor :person, :as => Person

  key :person_id, ObjectId
  key :user_refs, Integer, :default => 0

  many :comments, :class_name => 'Comment', :foreign_key => :post_id, :order => 'created_at ASC'
  belongs_to :person, :class_name => 'Person'

  timestamps!

  cattr_reader :per_page
  @@per_page = 10

  before_destroy :propogate_retraction
  after_destroy :destroy_comments

  def self.instantiate params
    self.create params.to_hash
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

