class Block < ActiveRecord::Base
  belongs_to :person
  belongs_to :user

  delegate :name, to: :person, prefix: true

  validates :user_id, :presence => true
  validates :person_id, :presence => true, :uniqueness => { :scope => :user_id }

  validate :not_blocking_yourself
  validate :not_blocking_podmin

  def not_blocking_yourself
    if self.user.person.id == self.person_id
      errors[:person_id] << "stop blocking yourself!"
    end
  end

  def not_blocking_podmin
    errors[:person_id] << t("blocks.create.failure.podmin") if Role.exists?(person_id: person_id, name: "admin")
  end
end
