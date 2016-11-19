class AddMissingUniqueIndexesOnSeveralTables < ActiveRecord::Migration
  def change
    remove_index :aspect_visibilities,
                 column: %i(shareable_id shareable_type aspect_id), name: "shareable_and_aspect_id"
    add_index :aspect_visibilities, %i(shareable_id shareable_type aspect_id), unique: true,
                                    name: "shareable_and_aspect_id", length: {shareable_type: 189}

    remove_index :participations, column: :guid, length: {guid: 191}
    add_index :participations, :guid, unique: true, length: {guid: 191}

    remove_index :services, column: %i(type uid)
    add_index :services, %i(type uid), unique: true

    add_index :aspects, %i(user_id name), unique: true, length: {name: 190}
    add_index :authorizations, %i(user_id o_auth_application_id), unique: true
    add_index :blocks, %i(person_id user_id), unique: true
    add_index :o_auth_applications, %i(client_name redirect_uris), length: {client_name: 191, redirect_uris: 190},
                                                                   unique: true
    add_index :ppid, %i(identifier user_id), unique: true, length: {identifier: 190}
    add_index :ppid, :guid, unique: true, name: "uniq_index_ppid_on_guid"
    add_index :roles, %i(person_id name), unique: true, length: {name: 190}
  end
end
