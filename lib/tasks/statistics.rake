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

  desc 'on content: posts, photos, status messages, comments'
  task :content => :environment do
    puts "Services: %i Facebook, %i Twitter" % [Services::Facebook.count, Services::Twitter.count]
    puts "Posts: %i and %i are public" % [Post.count, Post.where(:public => true).count]
    puts "Status messages: %i" % [StatusMessage.count, StatusMessage.where(:public => true).count]
    puts "Comments: %i" % Comment.count
    puts "Photos: %i" % Photo.count
  end
  task :genders => :environment do
    genders = Person.collection.group(['profile.gender'], {}, {:count => 0}, 'function(o,p) { p.count++; }', true )
    genders.sort!{|a,b| a['profile.gender'].to_s <=> b['profile.gender'].to_s}
    genders.each do |gender|
      puts "%s: %i" % [gender['profile.gender']||'none given', gender['count']]
    end
  end
end
