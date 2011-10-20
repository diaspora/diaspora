#this breaks seed scripts

unless !ActiveRecord::Base.connection.table_exists?('people') || Rails.env == 'test' || AppConfig[:community_spotlight].nil? || AppConfig[:community_spotlight].count == Person.community_spotlight.count
  print "Fetching community spotlight users from remote servers"
  AppConfig[:community_spotlight].each do |x|
    Webfinger.new(x).fetch
    print "."
  end
  puts " done!"
end
