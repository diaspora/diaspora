# frozen_string_literal: true

class Block < ApplicationRecord
  belongs_to :person
  belongs_to :user

  delegate :name, :diaspora_handle, to: :person, prefix: true

  validates :person_id, uniqueness: {scope: :user_id}

  validate :not_blocking_yourself

  def not_blocking_yourself
    return unless user.person.id == person_id

    errors.add(:person_id, "stop blocking yourself!")
  end

  # @return [Array<Person>] The recipient of the block
  def subscribers
    [person]
  end
end
