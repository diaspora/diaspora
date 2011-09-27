#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Aspect < ActiveRecord::Base
  belongs_to :user

  has_many :aspect_memberships, :dependent => :destroy
  has_many :contacts, :through => :aspect_memberships

  has_many :aspect_visibilities
  has_many :posts, :through => :aspect_visibilities
  
  validates :name, :presence => true, :length => { :maximum => 20 }

  validates_uniqueness_of :name, :scope => :user_id, :case_sensitive => false

  attr_accessible :name, :contacts_visible, :order_id

  before_validation do
    name.strip!
  end

  def to_s
    name
  end
end

