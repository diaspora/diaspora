FixtureBuilder.configure do |fbuilder|

  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir["app/models/*.rb", "lib/**/*.rb",  "spec/factories/*.rb", "spec/support/fixture_builder.rb"]

  # now declare objects
  fbuilder.factory do
    # Users
    alice = FactoryGirl.create(:user_with_aspect, :username => "alice", :strip_exif => false)
    alices_aspect = alice.aspects.where(:name => "generic").first

    eve   = FactoryGirl.create(:user_with_aspect, :username => "eve")
    eves_aspect = eve.aspects.where(:name => "generic").first

    bob   = FactoryGirl.create(:user_with_aspect, :username => "bob")
    bobs_aspect = bob.aspects.where(:name => "generic").first
    FactoryGirl.create(:aspect, :name => "empty", :user => bob)

    carol = FactoryGirl.create(:user_with_aspect, username: "carol")
    carols_aspect = carol.aspects.where(name: "generic").first

    debora = FactoryGirl.create(:user_with_aspect, username: "debora")
    deboras_aspect = carol.aspects.where(name: "generic").first

    connect_users(bob, bobs_aspect, alice, alices_aspect)
    connect_users(bob, bobs_aspect, eve, eves_aspect)
    connect_users(carol, carols_aspect, debora, deboras_aspect)

    # Set up friends - 2 local, 1 remote
    local_luke = FactoryGirl.create(:user_with_aspect, :username => "luke")
    lukes_aspect = local_luke.aspects.where(:name => "generic").first

    local_leia = FactoryGirl.create(:user_with_aspect, :username => "leia")
    leias_aspect = local_leia.aspects.where(:name => "generic").first

    remote_raphael = FactoryGirl.create(:person, :diaspora_handle => "raphael@remote.net")

    connect_users_with_aspects(local_luke, local_leia)

    local_leia.contacts.create(:person => remote_raphael, :aspects => [leias_aspect])
    local_luke.contacts.create(:person => remote_raphael, :aspects => [lukes_aspect])

    # Set up a follower
    peter = FactoryGirl.create(:user_with_aspect, :username => "peter")
    peters_aspect = peter.aspects.where(:name => "generic").first

    peter.contacts.create!(:person => alice.person,
                           :aspects => [peters_aspect],
                           :sharing => false,
                           :receiving => true)

    deboras_post = debora.post(:status_message,
                               text: "@{carol; #{carol.person.diaspora_handle}} you are silly",
                               to:   carols_aspect)

    # objects on post
    carol.like!(deboras_post)
    carol.comment!(deboras_post, "here are some thoughts on your post")
    deboras_post.reload

    # conversations
    create_conversation_with_message(carol.person, debora.person, "Subject", "Hey debora")

    # poll participation
    smwp = FactoryGirl.create(:status_message_with_poll)
    carol.participate_in_poll!(smwp, smwp.poll.poll_answers[0])

    # carol's own content
    carol.post(:status_message, text: "asldkfjs", to: carol.aspects.first)

    # user associated objects
    %w(mentioned liked reshared).each do |pref|
      carol.user_preferences.create!(email_type: pref)
    end

    # notifications
    3.times do
      FactoryGirl.create(:notification, recipient: carol)
    end

    NotificationActor.where(person_id: carol.person.id)

    # notifications for person (notification actors for carol)
    NotificationService.new.notify(
      carol.post(:status_message, text: "@{eve; #{eve.person.diaspora_handle}}", to: carol.aspects.first),
      [eve.id]
    )

    # tag followings
    TagFollowing.create!(tag: ActsAsTaggableOn::Tag.create!(name: "partytimeexcellent2"), user: carol)

    # services
    3.times do
      FactoryGirl.create(:service, user: carol)
    end

    # block
    carol.blocks.create!(person: eve.person)
    eve.blocks.create!(person: carol.person)

    FactoryGirl.create(:report_on_post, user: carol)

    FactoryGirl.create(:auth_with_read_and_write, user: carol)

    FactoryGirl.create(:role, person: carol.person)

    carol.invitation_code

    [carol.person, remote_raphael].each do |person|
      # posts
      posts = (1..3).map do
        FactoryGirl.create(:status_message, author: person)
      end

      posts.each do |post|
        person.contacts.each do |contact|
          ShareVisibility.create!(user_id: contact.user.id, shareable: post)
        end
      end

      # photos
      FactoryGirl.create(:photo, author: person)

      # mentions
      (1..3).map do
        FactoryGirl.create(:mention, person: person)
      end

      # conversations
      a_friend = person.contacts.first.user.person
      create_conversation_with_message(a_friend, person, "Subject", "Hey carol")
      create_conversation_with_message(person, a_friend, "Subject", "Hey carol")

      person.reload
    end
  end
end
