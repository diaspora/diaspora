class LinkShareVisibilitiesWithUser < ActiveRecord::Migration
  class ShareVisibility < ActiveRecord::Base
  end

  def up
    cleanup_deleted_share_visibilities

    remove_columns :share_visibilities, :created_at, :updated_at
    add_column :share_visibilities, :user_id, :integer

    # update_all from AR doesn't work with postgres, see: https://github.com/rails/rails/issues/13496
    if AppConfig.postgres?
      execute "UPDATE share_visibilities SET user_id = contacts.user_id " \
              "FROM contacts WHERE contacts.id = share_visibilities.contact_id"
    else
      ShareVisibility.joins("INNER JOIN contacts ON share_visibilities.contact_id = contacts.id")
        .update_all("share_visibilities.user_id = contacts.user_id")
    end

    remove_foreign_key :share_visibilities, name: :post_visibilities_contact_id_fk

    remove_index :share_visibilities, name: :index_post_visibilities_on_contact_id
    remove_index :share_visibilities, name: :shareable_and_contact_id
    remove_index :share_visibilities, name: :shareable_and_hidden_and_contact_id

    remove_column :share_visibilities, :contact_id

    ShareVisibility.joins("LEFT OUTER JOIN users ON users.id = share_visibilities.user_id")
      .delete_all("users.id is NULL")

    change_column :share_visibilities, :user_id, :integer, null: false

    add_index :share_visibilities, :user_id
    add_index :share_visibilities, %i(shareable_id shareable_type user_id), name: :shareable_and_user_id
    add_index :share_visibilities, %i(shareable_id shareable_type hidden user_id),
              name: :shareable_and_hidden_and_user_id

    add_foreign_key :share_visibilities, :users, name: :share_visibilities_user_id_fk, on_delete: :cascade
  end

  def down
    add_column :share_visibilities, :contact_id, :integer

    if AppConfig.postgres?
      execute "UPDATE share_visibilities SET contact_id = contacts.id " \
              "FROM contacts WHERE contacts.user_id = share_visibilities.user_id"
    else
      ShareVisibility.joins("INNER JOIN contacts ON share_visibilities.user_id = contacts.user_id")
        .update_all("share_visibilities.contact_id = contacts.id")
    end

    remove_foreign_key :share_visibilities, name: :share_visibilities_user_id_fk

    remove_index :share_visibilities, :user_id
    remove_index :share_visibilities, name: :shareable_and_user_id
    remove_index :share_visibilities, name: :shareable_and_hidden_and_user_id

    remove_column :share_visibilities, :user_id
    change_column :share_visibilities, :contact_id, :integer, null: false

    add_index :share_visibilities, :contact_id, name: :index_post_visibilities_on_contact_id
    add_index :share_visibilities, %i(shareable_id shareable_type contact_id), name: :shareable_and_contact_id
    add_index :share_visibilities, %i(shareable_id shareable_type hidden contact_id),
              name: :shareable_and_hidden_and_contact_id

    add_foreign_key :share_visibilities, :contacts, name: :post_visibilities_contact_id_fk, on_delete: :cascade

    add_column :share_visibilities, :created_at, :datetime
    add_column :share_visibilities, :updated_at, :datetime
  end

  private

  def cleanup_deleted_share_visibilities
    ShareVisibility.joins("LEFT OUTER JOIN posts ON posts.id = share_visibilities.shareable_id")
      .where(shareable_type: "Post").delete_all("posts.id is NULL")
    ShareVisibility.joins("LEFT OUTER JOIN photos ON photos.id = share_visibilities.shareable_id")
      .where(shareable_type: "Photo").delete_all("photos.id is NULL")
  end
end
