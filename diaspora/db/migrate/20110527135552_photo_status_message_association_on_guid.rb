class PhotoStatusMessageAssociationOnGuid < ActiveRecord::Migration
  class Post < ActiveRecord::Base
    attr_accessible :id, :guid, :status_message_id, :status_message_guid
    self.inheritance_column = :_type_disabled
  end

  def self.up
    add_column :posts, :status_message_guid, :string

    Post.record_timestamps = false
    photos = Post.where(Post.arel_table[:status_message_id].not_eq(nil).and(Post.arel_table[:type].eq('Photo')))
    photos.each do |photo|
      if Post.where(:id => photo.status_message_id).exists?
        status_message = Post.find(photo.status_message_id)
        photo.update_attributes(:status_message_guid => status_message.guid)
      end
    end

    remove_index :posts, [:status_message_id]
    remove_index :posts, [:status_message_id, :pending]
    add_index :posts, :status_message_guid
    add_index :posts, [:status_message_guid, :pending]

    remove_column :posts, :status_message_id
  end

  def self.down
    add_column :posts, :status_message_id, :integer

    Post.record_timestamps = false
    photos = Post.where(Post.arel_table[:status_message_guid].not_eq(nil).and(Post.arel_table[:type].eq('Photo')))
    photos.each do |photo|
      if Post.where(:guid => photo.status_message_guid).exists?
        status_message = Post.where(:guid => photo.status_message_guid).first
        photo.update_attributes(:status_message_id => status_message.id)
      end
    end

    remove_index :posts, [:status_message_guid, :pending]
    remove_index :posts, :status_message_guid
    add_index :posts, :status_message_id
    add_index :posts, [:status_message_id, :pending]

    remove_column :posts, :status_message_guid
  end
end
