#this breaks seed scripts

if AppConfig[:featured_users].present? && AppConfig[:community_spotlight].blank?
  AppConfig[:community_spotlight] = AppConfig[:featured_users]
  puts "DEPRICATION WARNING (10/21/11): Please change `featured_users` in your applicaiton.yml to `community_spotlight`.  Thanks!"
end

unless !ActiveRecord::Base.connection.table_exists?('people') || Rails.env == 'test' || AppConfig[:community_spotlight].nil? || AppConfig[:community_spotlight].count == Person.community_spotlight.count
  print "Fetching community spotlight users from remote servers"
  AppConfig[:community_spotlight].each do |x|
    Webfinger.new(x).fetch
    print "."
  end
  puts " done!"
end
