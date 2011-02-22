require File.join(File.dirname(__FILE__), "user_methods.rb")

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["app/models/*.rb", "lib/**/*.rb",  "spec/factories/*.rb", "spec/support/fixture_builder.rb"]

  # now declare objects
  fbuilder.factory do
    # Users
    alice = Factory(:user_with_aspect, :username => "alice")
    eve   = Factory(:user_with_aspect, :username => "eve")
    bob   = Factory(:user_with_aspect, :username => "bob")
    Factory(:aspect, :name => "empty", :user => bob)

    connect_users(bob, bob.aspects.first, alice, alice.aspects.first)
    connect_users(bob, bob.aspects.first, eve, eve.aspects.first)

    # Statistics
    frodo = Factory(:user_with_aspect, :username => "frodo")
    sam = Factory(:user_with_aspect, :username => "sam")
    bilbo = Factory(:user_with_aspect, :username => "bilbo")

    stat = Statistic.new
    time = Time.now

    1.times  { frodo.post_at_time(time) }
    5.times  { sam.post_at_time(time)   }
    10.times { bilbo.post_at_time(time) }

    (0..10).each do |n|
      stat.data_points << DataPoint.users_with_posts_on_day(time, n)
    end
    stat.time = time
    stat.save!
   end
end

