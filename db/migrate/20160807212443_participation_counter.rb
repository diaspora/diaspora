class ParticipationCounter < ActiveRecord::Migration
  class Comment < ActiveRecord::Base
  end

  class Like < ActiveRecord::Base
  end

  class Participation < ActiveRecord::Base
    belongs_to :author, class_name: "Person"
  end

  class Poll < ActiveRecord::Base
  end

  class PollParticipation < ActiveRecord::Base
    belongs_to :poll
  end

  def up
    return if ActiveRecord::SchemaMigration.where(version: "20150404193023").exists?

    add_column :participations, :count, :integer, null: false, default: 1

    likes_count = Like.select("COUNT(likes.id)")
                      .where("likes.target_id = participations.target_id")
                      .where("likes.author_id = participations.author_id")
                      .to_sql
    comments_count = Comment.select("COUNT(comments.id)")
                            .where("comments.commentable_id = participations.target_id")
                            .where("comments.author_id = participations.author_id")
                            .to_sql
    polls_count = PollParticipation.select("COUNT(*)")
                                   .where("poll_participations.author_id = participations.author_id")
                                   .joins(:poll)
                                   .where("polls.status_message_id = participations.target_id")
                                   .to_sql
    Participation.joins(:author).where.not(people: {owner_id: nil})
                 .update_all("count = (#{likes_count}) + (#{comments_count}) + (#{polls_count})")
    Participation.where(count: 0).update_all(count: 1)
  end

  def down
    remove_column :participations, :count

    ActiveRecord::SchemaMigration.where(version: "20150404193023").delete_all
  end
end
