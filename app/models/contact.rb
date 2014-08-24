#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Contact < ActiveRecord::Base
  belongs_to :user

  belongs_to :person
  validates :person, :presence => true

  delegate :name, :diaspora_handle, :guid, :first_name,
           to: :person, prefix: true

  has_many :aspect_memberships, :dependent => :destroy
  has_many :aspects, :through => :aspect_memberships

  has_many :share_visibilities, :source => :shareable, :source_type => 'Post'
  has_many :posts, :through => :share_visibilities, :source => :shareable, :source_type => 'Post'

  validate :not_contact_for_self,
           :not_blocked_user,
           :not_contact_with_closed_account

  validates_presence_of :user
  validates_uniqueness_of :person_id, :scope => :user_id

  before_destroy :destroy_notifications

  scope :all_contacts_of_person, ->(x) { where(:person_id => x.id) }

    # contact.sharing is true when contact.person is sharing with contact.user
  scope :sharing, -> { where(:sharing => true) }

  # contact.receiving is true when contact.user is sharing with contact.person
  scope :receiving, -> { where(:receiving => true) }

  scope :for_a_stream, -> {
    includes(:aspects, :person => :profile).
        order('profiles.last_name ASC')
  }

  scope :only_sharing, -> { sharing.where(:receiving => false) }

  def destroy_notifications
    Notification.where(:target_type => "Person",
                       :target_id => person_id,
                       :recipient_id => user_id,
                       :type => "Notifications::StartedSharing").destroy_all
  end

  def dispatch_request
    request = self.generate_request
    Postzord::Dispatcher.build(self.user, request).post
    request
  end

  def generate_request
    Request.diaspora_initialize(:from => self.user.person,
                :to => self.person,
                :into => aspects.first)
  end

  def receive_shareable(shareable)
    ShareVisibility.create!(:shareable_id => shareable.id, :shareable_type => shareable.class.base_class.to_s, :contact_id => self.id)
  end

  def contacts
    people = Person.arel_table
    incoming_aspects = Aspect.where(
      :user_id => self.person.owner_id,
      :contacts_visible => true).joins(:contacts).where(
        :contacts => {:person_id => self.user.person_id}).select('aspects.id')
    incoming_aspect_ids = incoming_aspects.map{|a| a.id}
    similar_contacts = Person.joins(:contacts => :aspect_memberships).where(
      :aspect_memberships => {:aspect_id => incoming_aspect_ids}).where(people[:id].not_eq(self.user.person.id)).select('DISTINCT people.*')
  end

  def mutual?
    self.sharing && self.receiving
  end

  def in_aspect? aspect
    if aspect_memberships.loaded?
      aspect_memberships.detect{ |am| am.aspect_id == aspect.id }
    elsif aspects.loaded?
      aspects.detect{ |a| a.id == aspect.id }
    else
      AspectMembership.exists?(:contact_id => self.id, :aspect_id => aspect.id)
    end
  end

  private
  def not_contact_with_closed_account
    if person_id && person.closed_account?
      errors[:base] << 'Cannot be in contact with a closed account'
    end
  end

  def not_contact_for_self
    if person_id && person.owner == user
      errors[:base] << 'Cannot create self-contact'
    end
  end

  def not_blocked_user
    if user && user.blocks.where(:person_id => person_id).exists?
      errors[:base] << 'Cannot connect to an ignored user'
      false
    else
      true
    end
  end
end

