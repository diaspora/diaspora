# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeletion < ApplicationRecord
  include Diaspora::Federated::Base

  scope :uncompleted, -> { where("completed_at is null") }

  belongs_to :person
  after_commit :queue_delete_account, on: :create

  delegate :diaspora_handle, to: :person

  def queue_delete_account
    Workers::DeleteAccount.perform_async(id)
  end

  def perform!
    Diaspora::Federation::Dispatcher.build(person.owner, self).dispatch if person.local?
    AccountDeleter.new(person).perform!
  end

  def subscribers
    person.owner.contact_people.remote | Person.who_have_reshared_a_users_posts(person.owner).remote
  end

  def public?
    true
  end
end
