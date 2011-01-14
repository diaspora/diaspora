namespace :statistics do
  desc 'on users: total, active'
  task :users => :environment do
    puts "Users: %i and %i incomplete" % [User.where(:getting_started => false).count,
        User.where(:getting_started => true, :sign_in_count.gt => 0).count]
    puts "Invitations sent: %i" % Invitation.count
    puts "Contacts: %i and %i pending" % [p = Contact.where(:pending => false).count, Contact.count - p]
    puts "Aspects: %i" % Aspect.count
    puts "Users signed in in last 24h: %i" % User.where(:current_sign_in_at.gt => Time.now - 1.day).count
    puts "Users signed in in last 7d: %i" % User.where(:current_sign_in_at.gt => Time.now - 7.days).count
  end

  task :users_splunk => :environment do
    puts "event=statistic, type=users, count=#{User.count}, "+
    "incomplete=#{User.where(:getting_started => true, :sign_in_count.gt => 0).count}, " +
    "last_1d=#{User.where(:current_sign_in_at.gt => Time.now - 1.days).count}, "+
    "last_7d=#{User.where(:current_sign_in_at.gt => Time.now - 7.days).count}, " +
    "notification_off=#{User.where(:disable_mail=>true).count}, "+
    "notification_off_%=#{User.where(:disable_mail=>true).count.to_f/User.count}, "+
    "no_invites=#{User.where(:invites => 0).count}, "+
    "last_7d_%=#{User.where(:current_sign_in_at.gt => Time.now - 7.days).count.to_f/User.count}, " +
    "last_7d_and_notifications_off_%=#{User.where(:current_sign_in_at.gt => Time.now - 7.days, :disable_mail => true).count.to_f/User.where(:disable_mail=>true).count}, " +
    "last_7d_and_no_invites_%=#{User.where(:current_sign_in_at.gt => Time.now - 7.days, :invites => 0).count.to_f/User.where(:invites => 0).count}"

   
    
    puts "event=statistic, type=invitations, count=#{Invitation.count}"
    puts "event=statistic, type=contacts, active_count=#{Contact.where(:pending => false).count}"
    puts "event=statistic, type=contacts, pending_count=#{Contact.where(:pending => true).count}"

    puts "event=statistic, type=aspect, count=#{ Aspect.count }"
  end

  desc 'on content: posts, photos, status messages, comments'
  task :content => :environment do
    puts "Services: %i Facebook, %i Twitter" % [Services::Facebook.count, Services::Twitter.count]
    puts "Posts: %i and %i are public" % [Post.count, Post.where(:public => true).count]
    puts "Status messages: %i" % [StatusMessage.count, StatusMessage.where(:public => true).count]
    puts "Comments: %i" % Comment.count
    puts "Photos: %i" % Photo.count
  end
  
  task :content_splunk => :environment do
    puts "event=statistic, type=posts, count=#{Post.count}, public_count=#{Post.where(:public => true).count}, public_% =#{Post.where(:public => true).count.to_f/Post.count}, " +
    "last_day = #{Post.where(:created_at.gt => Time.now - 1.days).count}, last_day_public_count=#{Post.where(:created_at.gt => Time.now - 1.days, :public => true).count}, "+
    "last_day_public_% = #{Post.where(:created_at.gt => Time.now - 1.days, :public => true).count.to_f/Post.where(:created_at.gt => Time.now - 1.days).count}"
  end

  task :genders => :environment do
    genders = Person.collection.group(['profile.gender'], {}, {:count => 0}, 'function(o,p) { p.count++; }', true )
    genders.sort!{|a,b| a['profile.gender'].to_s <=> b['profile.gender'].to_s}
    genders.each do |gender|
      puts "%s: %i" % [gender['profile.gender']||'none given', gender['count']]
    end
  end
end
