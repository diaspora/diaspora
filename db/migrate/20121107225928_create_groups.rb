class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string  :identifier, :null => false
      t.string  :name, :null => false
      t.text    :description
      t.string  :image_url
      # open, on-approval, add-only
      t.string  :admission, :null => false, :default => 'open'

      t.timestamps
    end

    add_index :groups, [:identifier], :unique => true

    create_table :group_membership_requests do |t|
      t.integer :group_id, :null => false
      t.integer :person_id, :null => false
      t.timestamps
    end
    add_index :group_membership_requests, [:group_id, :person_id], :unique => true

    create_table :group_members do |t|
      t.integer :group_id, :null => false
      t.integer :person_id, :null => false
      t.boolean :admin, :null => false, :default => false
      t.timestamps
    end

    add_index :group_members, [:group_id, :person_id], :unique => true

    create_table :group_posts do |t|
      t.integer :group_id, :null => false
      t.integer :post_id, :null => false
    end

    add_index :group_posts, [:group_id, :post_id], :unique => true
  end

  def self.down
    remove_index :group_posts, :column => [:group_id, :post_id]
    drop_table :group_posts
    remove_index :group_members, :column => [:group_id, :person_id]
    drop_table :group_members
    remove_index :groups, :column => [:identifier]
    drop_table :groups
  end
end
