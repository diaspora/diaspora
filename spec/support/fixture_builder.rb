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


    # Set up friends
    local_luke = Factory(:user_with_aspect, :username => "luke")
    local_leia = Factory(:user_with_aspect, :username => "leia")
    remote_raphael = Factory(:person, :diaspora_handle => "raphael@remote.net")
    connect_users_with_aspects(local_luke, local_leia)

    local_leia.contacts.create(:person => remote_raphael, :aspects => [local_leia.aspects.first])
    local_luke.contacts.create(:person => remote_raphael, :aspects => [local_luke.aspects.first])
   end
end

