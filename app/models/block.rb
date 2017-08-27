# frozen_string_literal: true

class Block < ApplicationRecord
  belongs_to :person
  belongs_to :user

  delegate :name, to: :person, prefix: true

  validates :person_id, uniqueness: {scope: :user_id}

  validate :not_blocking_yourself

  def not_blocking_yourself
    if self.user.person.id == self.person_id
      errors[:person_id] << "stop blocking yourself!"
    end
  end
end
