require File.join(Rails.root, 'lib', 'statistics' )

namespace :stats do
  desc 'Emails recent engagement statistics the admins'
  task :email_retention => :environment do

    return unless AppConfig[:admins].present? 

    admins =  User.find_all_by_username( AppConfig[:admins])

    require 'fastercsv'

    string = FasterCSV.generate do |csv|
      (0..32).each do |i|
        csv << [i.to_s, Statistics.new.retention(i)]
      end
    end

    Notifier.admin(string, admins, {:subject => "retention numbers #{Time.now.to_s}"})
  end
end
