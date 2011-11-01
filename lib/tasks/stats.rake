require File.join(Rails.root, 'lib', 'statistics' )

namespace :stats do
  desc 'Emails recent engagement statistics the admins'
  task :email_retention => :environment do
    require File.join(Rails.root, 'app', 'mailers', 'notifier' )

    return unless AppConfig[:admins].present? 

    admins =  User.find_all_by_username( AppConfig[:admins])

    require 'fastercsv'

    string = FasterCSV.generate do |csv|
      (0..32).each do |i|
        csv << [i.to_s, Statistics.new.retention(i)]
      end
    end

    emails = Notifier.admin( "here are some retention stats", admins, {:subject => "retention numbers #{Time.now.to_s}",
                            :attachments => [{:name => "retention_numbers_#{Time.now.to_s}.csv", :file => string}]})
    emails.each {|e| e.deliver} 
  end

  task :top_actives => :environment do

    require 'fastercsv'

    string = FasterCSV.generate do |csv|
      (0..32).each do |i|
        actives = ActiveRecord::Base.connection.select_all(Statistics.new.top_active_users(i).to_sql)
        actives.each do |a|
          csv << [i.to_s, a['email'], a['username'], a['first_name'], a['sign_in_count']]
        end
      end
    end

    File.open("#{Rails.root}/tmp/top_actives.csv", 'w') {|f| f.write(string) }
  end
end
