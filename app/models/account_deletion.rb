#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeletion < ActiveRecord::Base
  include Diaspora::Federated::Base


  belongs_to :person
  after_create :queue_delete_account

  attr_accessible :person

  xml_name :account_deletion
  xml_attr :diaspora_handle


  def person=(person)
    self[:diaspora_handle] = person.diaspora_handle
    self[:person_id] = person.id
  end

  def diaspora_handle=(diaspora_handle)
    self[:diaspora_handle] = diaspora_handle
    self[:person_id] ||= Person.find_by_diaspora_handle(diaspora_handle).id
  end

  def queue_delete_account
    Workers::DeleteAccount.perform_async(self.id)
  end

  def perform!
    self.dispatch if person.local?
    AccountDeleter.new(self.diaspora_handle).perform!
  end

  def subscribers(user)
    person.owner.contact_people.remote | Person.who_have_reshared_a_users_posts(person.owner).remote
  end

  def dispatch
    Postzord::Dispatcher.build(person.owner, self).post
  end

  def public?
    true
  end
end
