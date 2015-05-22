class Event < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid

  belongs_to :status_message
  has_many :event_participations

  xml_attr :name
  xml_attr :date
  xml_attr :location

  delegate :author, :author_id, :diaspora_handle, :public?, :subscribers, to: :status_message

  validates :name, presence: true
  validates :date, presence: true
  validates :location, presence: true

  self.include_root_in_json = false

  def as_json(options={})
    {
      :event_id => self.id,
      :post_id => self.status_message.id,
      :event_name => self.name,
      :event_date => self.date.strftime("%F %T"),
      :event_location => self.location
    }
  end

  def already_participated?(user)
    event_participations.where(:author_id => user.person.id).present?
  end
end
