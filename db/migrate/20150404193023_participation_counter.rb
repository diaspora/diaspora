class ParticipationCounter < ActiveRecord::Migration
  def up
    add_column :participations, :count, :int, null: false, default: 1

    comments_count = Comment.select("COUNT(comments.id)")
                     .where("comments.commentable_id = participations.target_id")
                     .where("comments.author_id = participations.author_id")
                     .to_sql

    Participation.update_all("count = (#{comments_count})")

    execute "UPDATE participations
              SET count = count + 1
              WHERE (participations.author_id, participations.target_id) in
                (SELECT posts.author_id, posts.id FROM posts)"

    execute "UPDATE participations
              SET count = count + 1
              WHERE (participations.author_id, participations.target_id) in
                (SELECT likes.author_id, likes.target_id FROM likes)"

    execute "UPDATE participations
              SET count = count + 1
              WHERE (participations.author_id, participations.target_id) in
                (SELECT poll_participations.author_id, polls.status_message_id
                 FROM poll_participations
                   INNER JOIN polls
                     ON polls.id = poll_participations.poll_id)"

    Participation.where(count: 0).delete_all
  end

  def down
    remove_column :participations, :count
  end
end
