class CleanupInvalidPolls < ActiveRecord::Migration[5.1]
  class Poll < ApplicationRecord
    has_many :poll_answers, dependent: :destroy
    has_many :poll_participations, dependent: :destroy
  end
  class PollAnswer < ApplicationRecord
    belongs_to :poll
    has_many :poll_participations
  end
  class PollParticipation < ApplicationRecord
    belongs_to :poll
    belongs_to :poll_answer
  end

  def up
    Poll.joins("LEFT OUTER JOIN posts ON posts.id = polls.status_message_id")
        .where("posts.id IS NULL").destroy_all
  end
end
