class AddMissingIndexesAcrossSeveralTables < ActiveRecord::Migration
  def change
    add_index :account_deletions, :person_id
    add_index :aspects, %i(:user_id, :order_id)
    add_index :authorizations, %i(:user_id :o_auth_application_id)
    add_index :blocks, :person_id
    add_index :blocks, :user_id
    add_index :blocks, %i(:person_id :user_id)
    add_index :invitation_codes, :user_id
    add_index :locations, :status_message_id
    add_index :notifications, %i(:id :type)
    add_index :photos, :author_id
    add_index :poll_participations, :author_id
    add_index :poll_participations, :poll_answer_id
    add_index :posts, :facebook_id
    add_index :posts, :o_embed_cache_id
    add_index :posts, :open_graph_cache_id
    add_index :ppid, :guid, unique: true
    add_index :reports, :user_id
    add_index :reports, %i(:item_id :item_type)
    add_index :roles, :person_id
    add_index :user_preferences, :user_id
    add_index :users, :auto_follow_back_aspect_id
    add_index :users, :invited_by_id
  end
end
