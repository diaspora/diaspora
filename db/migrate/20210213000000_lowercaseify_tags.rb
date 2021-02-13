# frozen_string_literal: true

class LowercaseifyTags < ActiveRecord::Migration[5.2]
  # We have to disable the global transaction for migrations, otherwise we
  # can't rescue from duplicates below. Checking if there are duplicates before
  # running the update would make this migration even more complicated, so...
  disable_ddl_transaction!

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def up
    # MySQL is case-insensitive by default. However, using utf8mb4_bin, it is
    # not. So, in theory, MySQL is affected by the same issue. Unfortunately,
    # MySQL does not support function indexes, so we can't simply run an index
    # on lower(name). The "solution" for MySQL is to add a generated column
    # and triggers to update that column.
    #
    # Since MySQL is deprecated from our POV anyway, and no new pods should
    # run MySQL - let's ignore this for now.
    return unless AppConfig.postgres?

    # Get all tag names for tags that are currently not completely lowercase
    affected_tags = query_first_field("SELECT DISTINCT lower(name) FROM tags WHERE lower(name) != name")

    Rails.logger.info "Merging duplicate tag entities for #{affected_tags.length} tags..."
    affected_tags.each do |tag_name|
      duplicate_tag_ids = query_first_field("SELECT id FROM tags WHERE lower(name) = '#{tag_name}' ORDER BY id ASC")

      # Take the lowest ID tag as the target
      target_tag_id = duplicate_tag_ids.shift

      duplicate_tag_ids.each do |duplicate_tag|
        # Note: Because things could be tagged with multiple cases of the same
        # tag, we can't simply update all taggings - it might create a
        # duplicate tagging violation...
        # Instead, query each tagging, try to update, and if it's a duplicate,
        # simply drop the tagging.

        # Do the aforementioned for taggings (posts, profiles, ...)
        query_first_field("SELECT id FROM taggings WHERE tag_id = #{duplicate_tag}").each do |tagging_id|
          begin
            execute("UPDATE taggings SET tag_id = #{target_tag_id} WHERE id = #{tagging_id}")
          rescue ActiveRecord::RecordNotUnique
            execute("DELETE FROM taggings WHERE id = #{tagging_id}")
          end
        end

        # Do the aforementioned for tag_followings (i.e. tag streams)
        query_first_field("SELECT id FROM tag_followings WHERE tag_id = #{duplicate_tag}").each do |tag_following_id|
          begin
            execute("UPDATE tag_followings SET tag_id = #{target_tag_id} WHERE id = #{tag_following_id}")
          rescue ActiveRecord::RecordNotUnique
            execute("DELETE FROM tag_followings WHERE id = #{tag_following_id}")
          end
        end

        # Delete the duplicate tag
        execute("DELETE FROM tags WHERE id = #{duplicate_tag}")
      end

      # Make sure the target tag is actually lowercase
      execute("UPDATE tags SET name = '#{tag_name}' WHERE id = #{target_tag_id}")

      # Re-count the taggings. I don't think this matters for us, but...
      ActsAsTaggableOn::Tag.reset_counters(target_tag_id, :taggings)
    end

    # Finally, create the new, now unique, index on the lowercase'd tag name
    add_index :tags, "lower(name)", name: "index_tags_on_lower_name", unique: true
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def down
    remove_index :tags, name: "index_tags_on_lower_name"
  end

  private

  def query_first_field(query)
    execute(query).values.map {|row| row[0] }
  end
end
