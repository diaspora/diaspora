unless Rails.env == 'test' || AppConfig[:featured_users].count == Person.featured_users.count
  puts "Fetching featured users from remote servers..."
  AppConfig[:featured_users].each do |x|
    Webfinger.new(x).fetch
  end
  puts "Done fetching!"
end
