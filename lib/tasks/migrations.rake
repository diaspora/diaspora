# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

namespace :migrations do

  desc 'copy all hidden share visibilities from share_visibilities to users. Can be run with the site still up.'
  task :copy_hidden_share_visibilities_to_users => [:environment] do
    require File.join(Rails.root, 'lib', 'share_visibility_converter')
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
    puts AppConfig[:s3_key]

    connection = Aws::S3.new( AppConfig[:s3_key], AppConfig[:s3_secret])
    bucket = connection.bucket('joindiaspora')
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
      good_tag = ActsAsTaggableOn::Tag.find_or_create_by_name(tag.name.downcase)
      puts "++ '#{tag.name}' has #{tag.taggings.count} records attached"
      deleteme = []

      tag.taggings.each do |tagging|
        deleteme << tagging
      end

      deleteme.each do |tagging|
        #tag.taggings.delete(tagging)
        good_tag.taggings << tagging
      end

      puts "-- converted '#{tag.name}' to '#{good_tag.name}' with #{deleteme.count} records"
      puts "\n## #{i} tags processed\n\n" if (i % 50 == 0)
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
