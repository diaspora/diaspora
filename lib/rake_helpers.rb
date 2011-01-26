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
end
