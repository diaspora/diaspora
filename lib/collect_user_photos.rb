module PhotoMover

  def self.move_photos(user)

    Dir.chdir Rails.root
    temp_dir = "tmp/exports/#{user.id}"
    FileUtils::mkdir_p temp_dir
    Dir.chdir 'tmp/exports'

    albums = user.visible_posts(:person_id => user.person.id, :_type => 'Album')

    albums.each do |album|
      album_dir = "#{user.id}/#{album.name}"
      FileUtils::mkdir_p album_dir

      album.photos.each do |photo|
        current_photo_location = "#{Rails.root}/public/uploads/images/#{photo.image_filename}"
        new_photo_location = "#{album_dir}/#{photo.image_filename}"

        FileUtils::cp current_photo_location new_photo_location
      end
    end

    system("tar", "cf #{user.id}.tar #{user.id}")
    FileUtils::rm_r user.id, :secure => true, :force => true

    "#{Rails.root}/#{temp_dir}.tar"
  end

end
