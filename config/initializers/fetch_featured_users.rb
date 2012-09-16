#this breaks seed scripts

unless AppConfig.prevent_fetching_community_spotlight?
  print "Fetching community spotlight users from remote servers"
  AppConfig.settings.community_spotlight.list.each do |x|
    Webfinger.new(x).fetch
    print "."
  end
  puts " done!"
end
