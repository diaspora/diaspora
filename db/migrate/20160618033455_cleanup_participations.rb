class CleanupParticipations < ActiveRecord::Migration
  class Participation < ActiveRecord::Base
  end

  def up
    remove_column :participations, :author_signature

    cleanup

    remove_index :participations, name: :index_participations_on_target_id_and_target_type_and_author_id
    add_index :participations, %i(target_id target_type author_id), unique: true
  end

  def down
    remove_index :participations, name: :index_participations_on_target_id_and_target_type_and_author_id
    add_index :participations, %i(target_id target_type author_id)
    add_column :participations, :author_signature, :text
  end

  private

  def cleanup
    self_where = "WHERE participations.target_type = 'Post' AND participations.target_id = posts.id AND " \
                 "posts.author_id = participations.author_id"
    remote_where = "WHERE participations.target_type = 'Post' AND participations.target_id = posts.id AND " \
                   "posts.author_id = post_author.id AND participations.author_id = author.id AND " \
                   "author.owner_id is NULL AND post_author.owner_id is NULL"
    duplicate_where = "WHERE p1.author_id = p2.author_id AND p1.target_id = p2.target_id " \
                      "AND p1.target_type = p2.target_type AND p1.id > p2.id"

    if AppConfig.postgres?
      execute "DELETE FROM participations USING posts #{self_where}"
      execute "DELETE FROM participations USING posts, people AS author, people AS post_author #{remote_where}"
      execute "DELETE FROM participations AS p1 USING participations AS p2 #{duplicate_where}"
    else
      execute "DELETE participations FROM participations, posts #{self_where}"
      execute "DELETE participations FROM participations, posts, people author, people post_author #{remote_where}"
      execute "DELETE p1 FROM participations p1, participations p2 #{duplicate_where}"
    end

    Participation.joins("LEFT OUTER JOIN posts ON posts.id = participations.target_id")
                 .where(target_type: "Post").delete_all("posts.id is NULL")
  end
end
