#NOTE add the person object you want to attach role to...
class Role < ActiveRecord::Base
  belongs_to :person

  scope :admins, -> { where(name: 'admin') }

  def self.is_admin?(person)
    find_by_person_id_and_name(person.id, 'admin')
  end

  def self.add_admin(person)
    find_or_create_by(person_id: person.id, name: 'admin')
  end

  def self.add_spotlight(person)
    find_or_create_by(person_id: person.id, name: 'spotlight')
  end
end
