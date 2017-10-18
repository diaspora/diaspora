# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

namespace :migrations do
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

  CURRENT_QUEUES = %w(urgent high medium low default).freeze

  desc "Migrate sidekiq jobs, retries, scheduled and dead jobs from any legacy queue to "\
       "the default queue (retries all dead jobs)"
  task :legacy_queues do
    Sidekiq.redis = AppConfig.get_redis_options

    # Push all retries, scheduled and dead jobs to their queues
    Sidekiq::RetrySet.new.retry_all
    Sidekiq::DeadSet.new.retry_all
    Sidekiq::ScheduledSet.new.reject {|job| CURRENT_QUEUES.include? job.queue }.each(&:add_to_queue)

    # Move all jobs from legacy queues to the default queue
    Sidekiq::Queue.all.each do |queue|
      next if CURRENT_QUEUES.include? queue.name

      puts "Migrating #{queue.size} jobs from #{queue.name} to default..."
      queue.each do |job|
        job.item["queue"] = "default"
        Sidekiq::Client.push(job.item)
        job.delete
      end

      # Delete the queue
      queue.clear
    end
  end

  desc "Run uncompleted account deletions"
  task run_account_deletions: :environment do
    if AccountDeletion.uncompleted.count > 0
      puts "Running account deletions..."
      AccountDeletion.uncompleted.find_each do |account_deletion|
        print "Deleting #{account_deletion.person.diaspora_handle} ..."
        progress = Thread.new {
          loop {
            sleep 10
            print "."
          }
        }
        account_deletion.perform!
        progress.kill
        puts " Done"
      end
      puts "OK."
    else
      puts "No account deletions to run."
    end
  end
end
