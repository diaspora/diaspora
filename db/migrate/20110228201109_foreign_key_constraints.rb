class ForeignKeyConstraints < ActiveRecord::Migration
  def self.up
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
