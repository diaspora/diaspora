# frozen_string_literal: true

def create_basic_users
  # Users
  alice = FactoryBot.create(:user_with_aspect, username: "alice", strip_exif: false)
  alices_aspect = alice.aspects.where(name: "generic").first

  eve = FactoryBot.create(:user_with_aspect, username: "eve")
  eves_aspect = eve.aspects.where(name: "generic").first

  bob = FactoryBot.create(:user_with_aspect, username: "bob")
  bobs_aspect = bob.aspects.where(name: "generic").first
  FactoryBot.create(:aspect, name: "empty", user: bob)

  connect_users(bob, bobs_aspect, alice, alices_aspect)
  connect_users(bob, bobs_aspect, eve, eves_aspect)

  # Set up friends - 2 local, 1 remote
  local_luke = FactoryBot.create(:user_with_aspect, username: "luke")
  lukes_aspect = local_luke.aspects.where(name: "generic").first

  local_leia = FactoryBot.create(:user_with_aspect, username: "leia")
  leias_aspect = local_leia.aspects.where(name: "generic").first

  remote_raphael = FactoryBot.create(:person, diaspora_handle: "raphael@remote.net")

  connect_users_with_aspects(local_luke, local_leia)

  local_leia.contacts.create(person: remote_raphael, aspects: [leias_aspect])
  local_luke.contacts.create(person: remote_raphael, aspects: [lukes_aspect])

  # Set up a follower
  peter = FactoryBot.create(:user_with_aspect, username: "peter")
  peters_aspect = peter.aspects.where(name: "generic").first

  peter.contacts.create!(person: alice.person, aspects: [peters_aspect], sharing: false, receiving: true)
end

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir[
    "app/models/*.rb", "lib/**/*.rb", "spec/factories/*.rb", "spec/support/fixture_builder.rb"
  ] - ["lib/diaspora/exporter.rb"]

  # now declare objects
  fbuilder.factory do
    create_basic_users
  end
end
