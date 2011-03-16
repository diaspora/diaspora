module PhotoMover
  def self.move_photos(user)
    Dir.chdir Rails.root
    temp_dir = "tmp/exports/#{user.id}"
    FileUtils::mkdir_p temp_dir
    Dir.chdir 'tmp/exports'

    photos = user.visible_posts(:author_id => user.person.id, :type => 'Photo')

    photos_dir = "#{user.id}/photos"
    FileUtils::mkdir_p photos_dir

    photos.each do |photo|
      current_photo_location = "#{Rails.root}/public/uploads/images/#{photo.remote_photo_name}"
      new_photo_location = "#{photos_dir}/#{photo.remote_photo_name}"
      FileUtils::cp current_photo_location, new_photo_location
    end

    `tar c #{user.id} > #{user.id}.tar`
    #system("tar", "c", "#{user.id}",">", "#{user.id}.tar")
    FileUtils::rm_r "#{user.id.to_s}/", :secure => true, :force => true

    "#{Rails.root}/#{temp_dir}.tar"
  end
end
