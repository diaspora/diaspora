class EventParticipation < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid
  include Diaspora::Relayable

  belongs_to :event
  belongs_to :author, :class_name => "Person", :foreign_key => :author_id

  xml_attr :diaspora_handle
  xml_attr :intention

  validate :not_already_participated
  validates :intention, presence: true

  enum intention: [ :no, :maybe, :yes ]

  def parent_class
    Event
  end

  def parent
    self.event
  end

  def parent= parent
    self.event = parent
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def not_already_participated
    return if event.nil?

    other_participations = EventParticipation.where(author_id: self.author.id, event_id: self.event.id).to_a-[self]
    if other_participations.present?
      self.errors.add(:event, I18n.t("activerecord.errors.models.event_participation.attributes.event.already_participated"))
    end
  end

  class Generator < Federated::Generator
    def self.federated_class
      EventParticipation
    end

    def initialize(person, target, intention)
      @intention = intention
      super(person, target)
    end

    def relayable_options
      {:event => @target.event}
    end
  end
end
