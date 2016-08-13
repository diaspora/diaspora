class CleanupInvitationColumnsFromUsers < ActiveRecord::Migration
  class InvitationCode < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end

  def change
    remove_index :users, column: %i(invitation_service invitation_identifier),
                 name: :index_users_on_invitation_service_and_invitation_identifier,
                 unique: true, length: {invitation_service: 64}
    remove_index :users, column: :invitation_token, name: :index_users_on_invitation_token
    remove_index :users, column: :email, name: :index_users_on_email, length: 191

    cleanup_invitations

    remove_column :users, :invitation_token, :string, limit: 60
    remove_column :users, :invitation_sent_at, :datetime
    remove_column :users, :invitation_service, :string, limit: 127
    remove_column :users, :invitation_identifier, :string, limit: 127
    remove_column :users, :invitation_limit, :integer
    remove_column :users, :invited_by_type, :string

    add_index :users, :email, name: :index_users_on_email, unique: true, length: 191
  end

  def cleanup_invitations
    reversible do |dir|
      dir.up do
        drop_table :invitations

        # reset negative invitation counters
        new_counter = AppConfig.settings.enable_registrations? ? AppConfig["settings.invitations.count"] : 0
        InvitationCode.where("count < 0").update_all(count: new_counter)

        # remove old invitation-users
        User.delete_all(username: nil)
        change_column :users, :username, :string, null: false
      end

      dir.down do
        change_column :users, :username, :string, null: true

        create_invitations_table
      end
    end
  end

  def create_invitations_table
    # rubocop:disable Style/ExtraSpacing
    create_table :invitations, force: :cascade do |t|
      t.text     :message,      limit: 65_535
      t.integer  :sender_id,    limit: 4
      t.integer  :recipient_id, limit: 4
      t.integer  :aspect_id,    limit: 4
      t.datetime :created_at,                                 null: false
      t.datetime :updated_at,                                 null: false
      t.string   :service,      limit: 255
      t.string   :identifier,   limit: 255
      t.boolean  :admin,                      default: false
      t.string   :language,     limit: 255,   default: "en"
    end
    # rubocop:enable Style/ExtraSpacing

    add_index :invitations, :aspect_id, name: :index_invitations_on_aspect_id, using: :btree
    add_index :invitations, :recipient_id, name: :index_invitations_on_recipient_id, using: :btree
    add_index :invitations, :sender_id, name: :index_invitations_on_sender_id, using: :btree

    add_foreign_key :invitations, :users, column: :recipient_id, name: :invitations_recipient_id_fk, on_delete: :cascade
    add_foreign_key :invitations, :users, column: :sender_id, name: :invitations_sender_id_fk, on_delete: :cascade
  end
end
