#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
module RakeHelpers
  def process_emails(csv, num_to_process, offset)
    require 'fastercsv'
    backers = FasterCSV.read(csv)    
    churn_through = 0
    num_to_process.times do |n|
      if backers[n+offset] == nil
        break
      end
      churn_through = n
      backer_name = backers[n+offset][0].to_s.strip
      backer_email = backers[n+offset][1].to_s.gsub('.ksr', '').strip
      puts "sending email to: #{backer_name} #{backer_email}"
      Invitation.create_invitee(:email => backer_email, :name => backer_name, :invites => 5)
    end
    churn_through
  end
end
