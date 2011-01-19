# I usually put this file in spec/support/fixture_builder.rb
FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["app/models/*.rb", "lib/**/*.rb",  "spec/factories/*.rb", "spec/support/fixture_builder.rb"]

  # now declare objects
  fbuilder.factory do
    alice = Factory(:user_with_aspect, :username => "alice")
    bob   = Factory(:user_with_aspect, :username => "bob")
    eve   = Factory(:user_with_aspect, :username => "eve")

    connect_users(bob, bob.aspects.first, alice, alice.aspects.first)
    connect_users(bob, bob.aspects.first, eve, eve.aspects.first)
   end
end

