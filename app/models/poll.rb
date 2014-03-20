class Poll < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid
  attr_accessible :question, :poll_answers
  belongs_to :status_message
  has_many :poll_answers
  has_many :poll_participations

  delegate :author, :author_id, :subscribers, to: :status_message

  #forward subscribers request to status message, because a poll is just attached to a status message and is not sharable itself
  #def subscribers(user)
  # 	status_message.subscribers(user)
  #end
end
