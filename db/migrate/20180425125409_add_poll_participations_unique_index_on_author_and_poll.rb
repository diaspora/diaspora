# frozen_string_literal: true

class AddPollParticipationsUniqueIndexOnAuthorAndPoll < ActiveRecord::Migration[5.1]
  def change
    reversible do |change|
      change.up do
        duplicate_query = "WHERE a1.poll_id = a2.poll_id AND a1.author_id = a2.author_id AND a1.id > a2.id"
        if AppConfig.postgres?
          execute("DELETE FROM poll_participations AS a1 USING poll_participations AS a2 #{duplicate_query}")
        else
          execute("DELETE a1 FROM poll_participations a1, poll_participations a2 #{duplicate_query}")
        end
      end
    end

    add_index :poll_participations, %i[poll_id author_id], unique: true
    remove_index :poll_participations, :poll_id
  end
end
