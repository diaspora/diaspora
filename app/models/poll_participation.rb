class PollParticipation < ActiveRecord::Base

  include Diaspora::Federated::Base
  
  include Diaspora::Guid
  include Diaspora::Relayable
  belongs_to :poll
  belongs_to :poll_answer, counter_cache: :vote_count
  belongs_to :author, :class_name => 'Person', :foreign_key => :author_id
  xml_attr :diaspora_handle
  xml_attr :poll_answer_guid
  xml_convention :underscore
  validate :not_already_participated

  def parent_class
    Poll
  end

  def parent
    self.poll
  end

  def poll_answer_guid
    poll_answer.guid
  end

  def poll_answer_guid= new_poll_answer_guid
    self.poll_answer = PollAnswer.where(:guid => new_poll_answer_guid).first
  end

  def parent= parent
    self.poll = parent
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def not_already_participated
    return if poll.nil?

    other_participations = PollParticipation.where(author_id: self.author.id, poll_id: self.poll.id).to_a-[self]
    if other_participations.present?
      self.errors.add(:poll, I18n.t("activerecord.errors.models.poll_participation.attributes.poll.already_participated"))
    end
  end

  class Generator < Federated::Generator
    def self.federated_class
      PollParticipation
    end

    def initialize(person, target, poll_answer)
      @poll_answer = poll_answer
      super(person, target)
    end

    def relayable_options
      {:poll => @target.poll, :poll_answer => @poll_answer}
    end
  end
end
