namespace :statistics do

  desc 'on users: total, active'
  namespace :users do
    def set_up_user_stats
      @users = User.where(:getting_started => false).count
      @incomplete = User.where("getting_started = TRUE AND sign_in_count >= 0").count
      @invitations = Invitation.count
      @contacts_active = Contact.where(:pending => false).count
      @contacts_pending = Contact.count - @contacts_active
      @aspects = Aspect.count
      @last_24_hrs = User.where("current_sign_in_at > '#{(Time.now - 1.day).to_date}'").count
      @last_7_d = User.where("current_sign_in_at > '#{(Time.now - 7.days).to_date}'").count

      @notification_off = User.where(:disable_mail=>true).count
      @notification_off_per = @notification_off.to_f / @users
      @no_invites = User.where(:invites => 0).count

      @sql = ActiveRecord::Base.connection
    end

    def users_with_x_posts(count)
      @sql.execute(
        "SELECT COUNT(*) FROM (SELECT `people`.guid, COUNT(*) AS posts_sum FROM `people` LEFT JOIN `posts` ON `people`.id = `posts`.person_id GROUP BY `people`.guid) AS t1 WHERE t1.posts_sum = #{count};"
      ).first[0]
    end

    def users_with_x_posts_today(count)
      @sql.execute(
        "SELECT COUNT(*) FROM (SELECT `people`.guid, COUNT(*) AS posts_sum FROM `people` LEFT JOIN `posts` ON `people`.id = `posts`.person_id AND `post`.created_at > '#{(Time.now - 1.days).to_date}' GROUP BY `people`.guid) AS t1 WHERE t1.posts_sum = #{count};"
      ).first[0]
    end

    def users_with_x_contacts(count)
      @sql.execute(
        "SELECT COUNT(*) FROM (SELECT `users`.id, COUNT(*) AS contact_sum FROM `users` LEFT JOIN `contacts` ON `users`.id = `contacts`.person_id AND `contacts`.pending = 0 GROUP BY `users`.id) AS t1 WHERE t1.contact_sum = #{count};"
      ).first[0]
    end

    task :human => :environment do
      set_up_user_stats
      puts "Users: %i and %i incomplete" % [@users, @incomplete]
      puts "Invitations sent: %i" % @invitations
      puts "Contacts: %i and %i pending" % [@contacts_active, @contacts_pending]
      puts "Aspects: %i" % @aspects
      puts "Users signed in in last 24h: %i" % @last_24_hrs
      puts "Users signed in in last 7d: %i" % @last_7_d

      puts "Users with more than one post: %i" % users_with_x_posts(1)
      puts "Users with more than five post: %i" % users_with_x_posts(5)
      puts "Users with more than ten post: %i" % users_with_x_posts(10)

      puts "Users with 1 or more contacts: %i" % users_with_x_contacts(0)
      puts "Users with 5 or more contacts: %i" % users_with_x_contacts(4)
      puts "Users with 10 or more contacts: %i" % users_with_x_contacts(9)
    end

    task :splunk => :environment do
      set_up_user_stats
      puts "event=statistic, type=users, count=#{@users}, "+
             "incomplete=#{@incomplete}, " +
             "last_1d=#{@last_24_hrs}, "+
             "last_7d=#{@last_7_d}, " +
             "notification_off=#{@notification_off}, "+
             "notification_off_%=#{@notification_off_per}, "+
             "no_invites=#{@no_invites}"


      puts "event=statistic, type=invitations, count=#{@invitations}"
      puts "event=statistic, type=contacts, active_count=#{@contacts_active}"
      puts "event=statistic, type=contacts, pending_count=#{@contacts_pending}"

      puts "event=statistic, type=aspect, count=#{@aspects}"
    end
  end

  desc 'on content: posts, photos, status messages, comments'
  namespace :content do
    task :human => :environment do
      puts "Services: %i Facebook, %i Twitter" % [Services::Facebook.count, Services::Twitter.count]
      puts "Posts: %i and %i are public" % [Post.count, Post.where(:public => true).count]
      puts "Status messages: %i" % [StatusMessage.count, StatusMessage.where(:public => true).count]
      puts "Comments: %i" % Comment.count
      puts "Photos: %i" % Photo.count
    end

    task :splunk => :environment do
      post_count = Post.count
      public_count = Post.where(:public => true).count
      public_per = public_count.to_f/post_count
      posts_last_day = Post.where("created_at > '#{(Time.now - 1.days).to_date}'").count
      posts_last_day_public = Post.where("created_at > '#{(Time.now - 1.days).to_date}' AND public = true").count
      posts_last_day_public_per = posts_last_day_public.to_f/posts_last_day

      puts "event=statistic, type=posts, count=#{post_count}, " +
             "public_count=#{public_count}, " +
             "public_%=#{public_per}, " +
             "last_day=#{posts_last_day}, " +
             "last_day_public_count=#{posts_last_day_public}, " +
             "last_day_public_%=#{posts_last_day_public_per}"
    end
  end
end
