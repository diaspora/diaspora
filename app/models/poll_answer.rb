class PollAnswer < ActiveRecord::Base

  include Diaspora::Federated::Base
  include Diaspora::Guid
  
  belongs_to :poll
  has_many :poll_participations

  xml_attr :answer

  def update_vote_counter
    self.vote_count = self.vote_count + 1
    self.save!
  end

end
