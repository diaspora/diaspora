namespace :fixtures do
  desc 'Regenerates user fixtures'
  task :users do
    puts "Regenerating fixtures for users."
    require File.join(Rails.root,"config/environment")
    require File.join(Rails.root,"spec/helper_methods")
    require File.join(Rails.root,"spec/factories")
    include HelperMethods
    UserFixer.regenerate_user_fixtures
    puts "Fixture regeneration complete."
  end
end
