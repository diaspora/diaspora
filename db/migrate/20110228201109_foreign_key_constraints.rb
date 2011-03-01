class ForeignKeyConstraints < ActiveRecord::Migration
  def self.disconnected_records dependent_table, dep_column, parent_table
    result = execute <<SQL
SELECT #{dependent_table}.id FROM #{dependent_table}
LEFT OUTER JOIN #{parent_table} ON #{dependent_table}.#{dep_column} = #{parent_table}.id
WHERE #{parent_table}.id IS NULL;
SQL
    result.to_a.flatten!
  end

  def self.delete_disconnected_records dependent_table, dep_column, parent_table
    bad_ids = disconnected_records dependent_table, dep_column, parent_table
    return unless bad_ids
    execute <<SQL
DELETE FROM #{dependent_table}
WHERE #{dependent_table}.id IN (#{bad_ids.join(',')});
SQL
  end

  def self.up
    [['aspect_memberships', 'contact_id', 'contacts'],
     ['aspect_memberships', 'aspect_id', 'aspects'],
     ['comments', 'post_id', 'posts'],
     ['comments', 'person_id', 'people'],
     ['posts', 'person_id', 'people'],
     ['contacts', 'person_id', 'people'],
     ['invitations', 'sender_id', 'users'],
     ['invitations', 'recipient_id', 'users'],
     ['notification_actors', 'notification_id', 'notifications'],
     ['profiles', 'person_id', 'people'],
     ['requests', 'sender_id', 'people'],
     ['requests', 'recipient_id', 'people'],
     ['services', 'user_id', 'users']
    ].each do |array|
      delete_disconnected_records array[0], array[1], array[2]
    end

    add_foreign_key(:aspect_memberships, :contacts, :dependent => :delete)
    add_foreign_key(:aspect_memberships, :aspects, :dependent => :restrict)

    add_foreign_key(:comments, :posts, :dependent => :delete)
    add_foreign_key(:comments, :people, :dependent => :delete)

    add_foreign_key(:posts, :people, :dependent => :delete)

    add_foreign_key(:contacts, :people, :dependent => :delete)

    add_foreign_key(:invitations, :users, :dependent => :delete, :column => :sender_id)
    add_foreign_key(:invitations, :users, :dependent => :delete, :column => :recipient_id)

    add_foreign_key(:notification_actors, :notifications, :dependent => :delete)

    add_foreign_key(:profiles, :people, :dependent => :delete)

    add_foreign_key(:requests, :people, :dependent => :delete, :column => :sender_id)
    add_foreign_key(:requests, :people, :dependent => :delete, :column => :recipient_id)

    add_foreign_key(:services, :users, :dependent => :delete)
  end

  def self.down
  end
end
