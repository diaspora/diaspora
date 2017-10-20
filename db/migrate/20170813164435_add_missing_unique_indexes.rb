# frozen_string_literal: true

class AddMissingUniqueIndexes < ActiveRecord::Migration[5.1]
  def up
    cleanup

    remove_index :aspect_visibilities, name: :shareable_and_aspect_id
    add_index :aspect_visibilities, %i[shareable_id shareable_type aspect_id],
              name: :index_aspect_visibilities_on_shareable_and_aspect_id,
              length: {shareable_type: 189}, unique: true

    add_index :blocks, %i[user_id person_id], name: :index_blocks_on_user_id_and_person_id, unique: true

    add_index :roles, %i[person_id name], name: :index_roles_on_person_id_and_name, length: {name: 190}, unique: true
  end

  def down
    remove_index :aspect_visibilities, name: :index_aspect_visibilities_on_shareable_and_aspect_id
    add_index :aspect_visibilities, %i[shareable_id shareable_type aspect_id], name: :shareable_and_aspect_id,
              length: {shareable_type: 189}, unique: true

    remove_index :blocks, name: :index_blocks_on_user_id_and_person_id

    remove_index :roles, name: :index_roles_on_person_id_and_name
  end

  def cleanup
    aspect_visibilities_where = "WHERE a1.shareable_id = a2.shareable_id AND a1.shareable_type = a2.shareable_type " \
                                "AND a1.aspect_id = a2.aspect_id AND a1.id > a2.id"
    blocks_where = "WHERE b1.user_id = b2.user_id AND b1.person_id = b2.person_id AND b1.id > b2.id"
    roles_where = "WHERE r1.person_id = r2.person_id AND r1.name = r2.name AND r1.id > r2.id"

    if AppConfig.postgres?
      execute "DELETE FROM aspect_visibilities AS a1 USING aspect_visibilities AS a2 #{aspect_visibilities_where}"
      execute "DELETE FROM blocks AS b1 USING blocks AS b2 #{blocks_where}"
      execute "DELETE FROM roles AS r1 USING roles AS r2 #{roles_where}"
    else
      execute "DELETE a1 FROM aspect_visibilities a1, aspect_visibilities a2 #{aspect_visibilities_where}"
      execute "DELETE b1 FROM blocks b1, blocks b2 #{blocks_where}"
      execute "DELETE r1 FROM roles r1, roles r2 #{roles_where}"
    end
  end
end
