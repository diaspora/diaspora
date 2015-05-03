# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

namespace :migrations do

  desc 'copy all hidden share visibilities from share_visibilities to users. Can be run with the site still up.'
  task :copy_hidden_share_visibilities_to_users => [:environment] do
    require Rails.root.join('lib', 'share_visibility_converter')
    ShareVisibilityConverter.copy_hidden_share_visibilities_to_users
  end

  desc 'puts out information about old invited users'
  task :invitations => [:environment] do
    puts "email, invitation_token, :invited_by_id, :invitation_identifier"
    User.where('username is NULL').select([:id, :email, :invitation_token, :invited_by_id, :invitation_identifier]).find_in_batches do |users|
      users.each{|x| puts "#{x.email}, #{x.invitation_token}, #{x.invited_by_id}, #{x.invitation_identifier}" }
    end
    puts "done"
  end

  desc 'absolutify all existing image references'
  task :absolutify_image_references do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')

    Photo.all.each do |photo|
      unless photo.remote_photo_path
        # extract root
        #
        pod = URI::parse(photo.person.url)
        pod_url = "#{pod.scheme}://#{pod.host}"

        if photo.image.url
          remote_path = "#{photo.image.url}"
        else
          puts pod_url
          remote_path = "#{pod_url}#{photo.remote_photo_path}/#{photo.remote_photo_name}"
        end

        # get path/filename
        name_start = remote_path.rindex '/'
        photo.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
        photo.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)

        photo.save!
      end
    end
  end

  task :upload_photos_to_s3 do
    require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
    puts AppConfig.environment.s3.key

    connection = Aws::S3.new( AppConfig.environment.s3.key, AppConfig.environment.s3.secret)
    bucket = connection.bucket(AppConfig.environment.s3.bucket)
    dir_name = File.dirname(__FILE__) + "/../../public/uploads/images/"

    count = Dir.foreach(dir_name).count
    current = 0

    Dir.foreach(dir_name){|file_name| puts file_name;
      if file_name != '.' && file_name != '..';
        begin
          key = Aws::S3::Key.create(bucket, 'uploads/images/' + file_name);
          key.put(File.open(dir_name+ '/' + file_name).read, 'public-read');
          key.public_link();
          puts "Uploaded #{current} of #{count}"
          current += 1
        rescue => e
          puts "error #{e} on #{current} (#{file_name}), retrying"
          retry
        end
      end
    }

  end

  # removes hashtags with uppercase letters and re-attaches
  # the posts to the lowercase version
  task :rewire_uppercase_hashtags => :environment do
    evil_tags = ActsAsTaggableOn::Tag.where("lower(name) != name")
    puts "found #{evil_tags.count} tags to convert..."

    evil_tags.each_with_index do |tag, i|
      good_tag = ActsAsTaggableOn::Tag.first_or_create_by(name: tag.name.mb_chars.downcase)
      puts "++ '#{tag.name}' has #{tag.taggings.count} records attached"

      taggings = tag.taggings
      deleteme = []

      taggings.each do |tagging|
        if good_tag.taggings.where(:taggable_id => tagging.taggable_id).count > 0
          # the same taggable is already tagged with the correct tag
          # just delete the obsolete tagging it
          deleteme << tagging
          next
        end

        # the tagging exists only for the wrong tag, move it to the 'good tag'
        good_tag.taggings << tagging
      end

      deleteme.each do |tagging|
        tagging.destroy
      end

      rest = tag.taggings(true) # force reload
      if rest.count > 0
        puts "-- the tag #{tag.name} still has some taggings - aborting!"
        break
      end

      # no more taggings left, delete the tag
      tag.destroy

      puts "-- converted '#{tag.name}' to '#{good_tag.name}'"
      puts "\n## #{i+1} tags processed\n\n" if ((i+1) % 50 == 0)
    end
  end

  task :remove_uppercase_hashtags => :environment do
    evil_tags = ActsAsTaggableOn::Tag.where("lower(name) != name")
    evil_tags.each do |tag|
      next if tag.taggings.count > 0 # non-ascii tags

      puts "removing '#{tag.name}'..."
      tag.destroy
    end
  end
end
