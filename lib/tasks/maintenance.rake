#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :maintenance do
  APP_ROOT = File.expand_path( File.join( File.dirname( __FILE__ ), '..', '..') )
  desc "Clear CarrierWave temp uploads"
  task :clear_carrierwave_temp_uploads do
    filename = File.join( APP_ROOT, 'tmp', 'uploads', '*')
    today_string = Time.now.strftime( '%Y%m%d' )
    Dir.glob( filename ) do |file|
      unless file.include?( today_string )
        FileUtils.rm_rf( file )
      end
    end
  end

  desc "Rotate Diaspora logs"
  task :install_logrotate_config do
    logrotate_conf = <<-RUBY
#{APP_ROOT}/logs/production.log {
  daily
  missingok
  rotate 8
  compress
  delaycompress
  notifempty
  copytruncate
}
RUBY
    begin
      File.open('/etc/logrotate.d/diaspora') do |fin|
        fin.write logrotate_conf
      end
    rescue
      puts "Could not install logrotate configs. Perhaps you should try running this task as root and ensuring logrotate is installed:\n#{logrotate_conf}"
    end
  end
  
  desc "Queue users for removal"
  task :queue_users_for_removal => :environment do
    # Queue users for removal due to inactivity
    # Note! settings.maintenance.remove_old_users
    # must still be enabled, this only bypasses
    # scheduling to run the queuing immediately
    Workers::QueueUsersForRemoval.perform_async
  end
end
