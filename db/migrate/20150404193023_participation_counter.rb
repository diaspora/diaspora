class ParticipationCounter < ActiveRecord::Migration
  def up
    add_column :participations, :count, :int, null: false, default: 1

    posts_count = Post.select("COUNT(posts.id)")
                  .where("posts.id = participations.target_id")
                  .where("posts.author_id = participations.author_id")
                  .to_sql
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
    Participation.update_all("count = (#{posts_count}) + (#{likes_count}) + (#{comments_count}) + (#{polls_count})")
    Participation.where(count: 0).delete_all
  end

  def down
    remove_column :participations, :count
  end
end
