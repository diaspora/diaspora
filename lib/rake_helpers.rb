#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
module RakeHelpers

  def process_emails(csv, num_to_process, offset, test=true)
    if RUBY_VERSION.include? "1.8"

       require 'fastercsv'
       backers = FasterCSV.read(csv)
     else
       require 'csv'
       backers = CSV.read(csv)
     end
    puts "DRY RUN" if test
    churn_through = 0
    num_to_process.times do |n|
      if backers[n+offset] == nil
        break
      end
      churn_through = n
      backer_name = backers[n+offset][1].to_s.strip
      backer_email = backers[n+offset][0].to_s.strip.downcase
      
      possible_user = User.find_by_email(backer_email)
      possible_invite = Invitation.find_by_identifier(backer_email)
      possible_user ||= possible_invite.recipient if possible_invite.present?

      admin_account = User.find_by_username(AppConfig[:admin_account])
      raise "no admin_account in application.yml" unless admin_account.present?
      admin_account.invitation_code.count += num_to_process
      admin_account.invitation_code.save

      unless possible_user
        puts "#{n}: sending email to: #{backer_name} #{backer_email}" unless Rails.env == 'test'
        unless test
          i = EmailInviter.new(backer_email)
          i.send!
        end
      else
        puts "user with the email exists: #{backer_email} ,  #{backer_name} " unless Rails.env == 'test'
      end
    end
    churn_through
  end
end
