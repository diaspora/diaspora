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
        Invitation.create_invitee(:service => 'email', :identifier => backer_email, :name => backer_name, :invites => num_invites) unless test
      else
        puts "user with the email exists: #{backer_email} ,  #{backer_name} " unless Rails.env == 'test'
      end
    end
    churn_through
  end

  def prune_yesterdays_backups(f)
    filenames = f.clone
    filenames.sort!.map!{|d| d.delete('.tar')}

    groups = filenames.group_by do |x|
      Time.at(x.to_i).strftime('%m%d%Y')
    end

    today = Time.now.strftime('%m%d%Y')
    yesterday = 1.day.ago.strftime('%m%d%Y')
    to_delete = []
    if groups[today].count > 23  # if this is the 24th backup of the day
      puts groups[yesterday].count
      groups[yesterday].pop
      to_delete = groups[yesterday]
      puts groups[yesterday].count
    end

    to_delete.map!{|x| x + '.tar'}
  end
end
