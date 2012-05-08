#NOTE add the person object you want to attach role to...
class Role < ActiveRecord::Base
  belongs_to :person

  def self.is_admin?(person)
    find_by_person_id_and_name(person.id, 'admin')
  end

  def self.is_beta?(person)
    find_by_person_id_and_name(person.id, 'beta').present?
  end

  def self.add_beta(person)
    find_or_create_by_person_id_and_name(person.id, 'beta')
  end

  def self.add_admin(person)
    find_or_create_by_person_id_and_name(person.id, 'admin')
  end

  def self.add_spotlight(person)
    find_or_create_by_person_id_and_name(person.id, 'spotlight')
  end

  def self.load_admins
    admins = AppConfig[:admins] || []
    admins.each do |username|
      u = User.find_by_username(username)
      find_or_create_by_person_id_and_name(u.person.id, 'admin')
    end
  end

  def self.load_spotlight
    spotlighters = AppConfig[:community_spotlight] || []
    spotlighters.each do |diaspora_handle|
      person = Person.find_by_diaspora_handle(diaspora_handle) 
      find_or_create_by_person_id_and_name(person.id, 'spotlight')
    end
  end
end