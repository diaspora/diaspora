# frozen_string_literal: true

namespace :podmin do
  
  desc "Send an email to users as admin"
  task :admin_mail, [:users_def, :msg_path, :subject] => :environment do |t, args|
    if args[:users_def] == 'all'
      # to all except deleted and deactivated, of course
      users = User.where("locked_at is null and username is not null")
    elsif args[:users_def] == 'active_yearly'
      users = User.yearly_actives
    elsif args[:users_def] == 'active_monthly'
      users = User.monthly_actives
    elsif args[:users_def] == 'active_halfyear'
      users = User.halfyear_actives
    end
    msg = File.read(args[:msg_path])
    mails = Notifier.admin(msg.html_safe, users, :subject => args[:subject])
    count = 0
    mails.each do |mail|
      begin
        mail.deliver
        count += 1
        if count % 100 == 0
          puts "#{count} out of #{mails.count} delivered"
        end
      rescue
        puts $!, $@
      end
    end
    puts "#{count} out of #{mails.count} delivered"
  end
  
end