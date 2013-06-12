class FixPhotoShareVisibilities < ActiveRecord::Migration
  class Photo < ActiveRecord::Base; end

  def self.up
    return  if ! Photo.first.respond_to?(:tmp_old_id)

    if AppConfig.postgres?
      ['aspect_visibilities', 'share_visibilities'].each do |vis_table|
        execute "UPDATE #{vis_table} SET shareable_type = 'Post'"

        execute %{
          UPDATE
            #{vis_table}
          SET
              shareable_type = 'Photo'
            , shareable_id   = photos.id
          FROM
            photos
          WHERE
            #{vis_table}.shareable_id = photos.tmp_old_id
        }
      end
    else
      ['aspect_visibilities', 'share_visibilities'].each do |vis_table|
        ActiveRecord::Base.connection.execute <<SQL
        UPDATE #{vis_table}
          SET shareable_type='Post'
SQL
        ActiveRecord::Base.connection.execute <<SQL
        UPDATE #{vis_table}, photos
          SET #{vis_table}.shareable_type='Photo', #{vis_table}.shareable_id=photos.id
            WHERE #{vis_table}.shareable_id=photos.tmp_old_id
SQL
      end
    end
  end

  def self.down
  end
end
