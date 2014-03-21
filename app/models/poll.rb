class Poll < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid
  attr_accessible :question, :poll_answers
  belongs_to :status_message
  has_many :poll_answers
  has_many :poll_participations

  #forward some requests to status message, because a poll is just attached to a status message and is not sharable itself
  delegate :author, :author_id, :public?, :subscribers, to: :status_message

end
