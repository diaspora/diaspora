#this breaks seed scripts

unless !ActiveRecord::Base.connection.table_exists?('people') || Rails.env == 'test' || AppConfig[:featured_users].nil? || AppConfig[:featured_users].count == Person.featured_users.count
  print "Fetching featured users from remote servers"
  AppConfig[:featured_users].each do |x|
    Webfinger.new(x).fetch
    print "."
  end
  puts " done!"
end
