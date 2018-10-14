# frozen_string_literal: true

# NOTE add the person object you want to attach role to...

class Role < ApplicationRecord
  belongs_to :person

  validates :name, uniqueness: {scope: :person_id}
  validates :name, inclusion: {in: %w(admin moderator spotlight)}

  scope :admins, -> { where(name: "admin") }
  scope :moderators, -> { where(name: %w(moderator admin)) }

  def self.is_admin?(person)
    exists?(person_id: person.id, name: "admin")
  end

  def self.add_admin(person)
    find_or_create_by(person_id: person.id, name: "admin")
  end

  def self.remove_admin(person)
    find_by(person_id: person.id, name: "admin").destroy
  end

  def self.moderator?(person)
    moderators.exists?(person_id: person.id)
  end

  def self.moderator_only?(person)
    exists?(person_id: person.id, name: "moderator")
  end

  def self.add_moderator(person)
    find_or_create_by(person_id: person.id, name: "moderator")
  end

  def self.remove_moderator(person)
    find_by(person_id: person.id, name: "moderator").destroy
  end

  def self.spotlight?(person)
    exists?(person_id: person.id, name: "spotlight")
  end

  def self.add_spotlight(person)
    find_or_create_by(person_id: person.id, name: "spotlight")
  end

  def self.remove_spotlight(person)
    find_by(person_id: person.id, name: "spotlight").destroy
  end
end
