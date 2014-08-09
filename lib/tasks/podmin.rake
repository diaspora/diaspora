namespace :podmin do
  
  desc <<DESC
  Send an email to users as admin.
  Parameters
    users def
      "all", "active_yearly", "active_monthly" or "active_halfyear"
    msg_path
      path to a file that contains the HTML message to send
DESC
  task :admin_mail, [:users_def, :msg_path] => :environment do |t, args|
    if args[:users_def] == 'all'
      # to all except deleted and deactivated, of course
      users = User.where(locked_at: nil)
    elsif args[:users_def] == 'active_yearly'
      users = User.yearly_actives
    elsif args[:users_def] == 'active_monthly'
      users = User.monthly_actives
    elsif args[:users_def] == 'active_halfyear'
      users = User.halfyear_actives
    end
    file = File.open(args[:msg_path])
    msg = file.read
    file.close
    mails = Notifier.admin(msg.html_safe, users)
    mails.each(&:deliver)
  end
  
end