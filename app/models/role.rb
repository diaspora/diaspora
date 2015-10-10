# NOTE add the person object you want to attach role to...

class Role < ActiveRecord::Base
  belongs_to :person

  validates :person, presence: true
  validates :name, uniqueness: {scope: :person_id}
  validates :name, inclusion: {in: %w(admin moderator spotlight)}

  scope :admins, -> { where(name: "admin") }
  scope :moderators, -> { where(name: %w(moderator admin)) }

  def self.admin?(person_id)
    exists?(person_id: person_id, name: "admin")
  end

  def self.add_admin(person)
    find_or_create_by(person_id: person.id, name: "admin")
  end

  def self.moderator?(person_id)
    moderators.exists?(person_id: person_id)
  end

  def self.add_moderator(person)
    find_or_create_by(person_id: person.id, name: "moderator")
  end

  def self.spotlight?(person_id)
    exists?(person_id: person_id, name: "spotlight")
  end

  def self.add_spotlight(person)
    find_or_create_by(person_id: person.id, name: "spotlight")
  end
end
