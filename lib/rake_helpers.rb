#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
module RakeHelpers
  def process_emails(csv, num_to_process, offset, num_invites=10, test=true)
    if RUBY_VERSION.include? "1.8"
       require 'fastercsv'
       backers = FasterCSV.read(csv)  
     else
       require 'csv'
       backers = CSV.read(csv)
     end
    puts "IN TEST MODE" if test
    churn_through = 0
    num_to_process.times do |n|
      if backers[n+offset] == nil
        break
      end
      churn_through = n
      backer_name = backers[n+offset][0].to_s.strip
      backer_email = backers[n+offset][1].to_s.gsub('.ksr', '').strip
      unless User.find_by_email(backer_email) 
        puts "sending email to: #{backer_name} #{backer_email}" unless Rails.env == 'test'
        Invitation.create_invitee(:email => backer_email, :name => backer_name, :invites => num_invites) unless test
      else
        puts "user with the email exists: #{backer_email} ,  #{backer_name} " unless Rails.env == 'test'
      end
    end
    churn_through
  end

  def fix_diaspora_handle_spaces(test = true)
    offenders = {}
    space_people = Person.all(:diaspora_handle => / /, :url => AppConfig[:pod_url])  # this is every person with a space....

    #these people dont even have users.... they are totally messed up
    totally_messed_up_people = space_people.find_all{|x| x.owner.nil?}
    totally_messed_up_people.each{|x| x.delete}

    space_people = Person.all(:diaspora_handle => / /, :owner_id.ne => nil, :url => AppConfig[:pod_url])  # this is every person with a space....

    space_people.each do |person|
      user = person.owner
      new_diaspora_handle = new_diaspora_handle(user) 
      update_my_posts_with_new_diaspora_handle(user, new_diaspora_handle, test)
      person.diaspora_handle = new_diaspora_handle

      if test 
        (puts "TEST:saving person w/handle #{person.diaspora_handle}") 
      else
         person.save(:safe => true)
      end

mail =  <<mail
      You may have noticed that your Diaspora handle contained spaces, or was different than your login name.
      This was due to a weird error in the early days of Diaspora, and while we fixed the bug,
      there still may have been a problem with your account.  When logging into your account #{user.username},
      your Diaspora handle is now #{person.diaspora_handle}.  Sorry for the confusion!
mail
      Notifier.admin(mail, [user]).each{|x| x.deliver unless test}
    end
  end

  def new_diaspora_handle(user)
    "#{user.username}@#{AppConfig[:pod_uri].host}"
  end

  def update_my_posts_with_new_diaspora_handle(user, new_diaspora_handle, test)
     user.my_posts.all.each do |post|
        post.diaspora_handle = new_diaspora_handle
        if test  
          (puts "TEST: saving post w/id #{post.id}")
        else
          post.save(:safe => true)
        end
      end
  end

  def fix_periods_in_username(test = true)
    bad_users = User.all(:username => /\./)
    bad_users.each do |bad_user|
      bad_user.username.delete!('.')
      bad_user.username.delete!(' ')
      new_diaspora_handle = new_diaspora_handle(bad_user)

      update_my_posts_with_new_diaspora_handle(bad_user, new_diaspora_handle, test)
      bad_user.person.diaspora_handle = new_diaspora_handle
      
      if test
        puts "saving person and user with #{new_diaspora_handle}"
      else
        bad_user.person.save(:safe => true)
        bad_user.save(:safe => true)
      end



mail =  <<mail
      We noticed that your Diaspora username contained periods.
      This was due to a weird error in the early days of Diaspora, and while we fixed the bug,
      there still may have been a problem with your account.  Log into your account with #{bad_user.username},
      you improved, period-less, username!
mail
      Notifier.admin(mail, [bad_user]).each{|x| x.deliver unless test}
    end
  end
end
