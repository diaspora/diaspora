#   Copyright (c) 2010-2011, Diaspora In  This file is
#   licensed under the Affero General Public License version 3 or late  See
#   the COPYRIGHT file.

#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures

def r_str
  SecureRandom.hex(3)
end

require "diaspora_federation/test"
DiasporaFederation::Test::Factories.federation_factories

FactoryGirl.define do
  factory :profile do
    sequence(:first_name) { |n| "Robert#{n}#{r_str}" }
    sequence(:last_name)  { |n| "Grimm#{n}#{r_str}" }
    bio "I am a cat lover and I love to run"
    gender "robot"
    location "Earth"
    birthday Date.today
  end

  factory :profile_with_image_url, :parent => :profile do
    image_url "http://example.com/image.jpg"
    image_url_medium "http://example.com/image_mid.jpg"
    image_url_small "http://example.com/image_small.jpg"
  end

  factory(:person, aliases: %i(author)) do
    sequence(:diaspora_handle) {|n| "bob-person-#{n}#{r_str}@example.net" }
    url AppConfig.pod_uri.to_s
    serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
    after(:build) do |person|
      unless person.profile.first_name.present?
        person.profile = FactoryGirl.build(:profile, person: person)
      end
    end
    after(:create) do |person|
      person.profile.save
    end
  end

  factory :account_deletion do
    association :person
    after(:build) do |delete|
      delete.diaspora_handle = delete.person.diaspora_handle
    end
  end

  factory :searchable_person, :parent => :person do
    after(:build) do |person|
      person.profile = FactoryGirl.build(:profile, :person => person, :searchable => true)
    end
  end

  factory :like do
    association :author, :factory => :person
    association :target, :factory => :status_message
  end

  factory :user do
    getting_started false
    sequence(:username) { |n| "bob#{n}#{r_str}" }
    sequence(:email) { |n| "bob#{n}#{r_str}@pivotallabs.com" }
    password "bluepin7"
    password_confirmation { |u| u.password }
    serialized_private_key  OpenSSL::PKey::RSA.generate(1024).export
    after(:build) do |u|
      u.person = FactoryGirl.build(:person, :profile => FactoryGirl.build(:profile),
                                  :owner_id => u.id,
                                  :serialized_public_key => u.encryption_key.public_key.export,
                                  :diaspora_handle => "#{u.username}#{User.diaspora_id_host}")
    end
    after(:create) do |u|
      u.person.save
      u.person.profile.save
    end
  end

  factory :user_with_aspect, :parent => :user do
    after(:create) { |u|  FactoryGirl.create(:aspect, :user => u) }
  end

  factory :aspect do
    name "generic"
    user
  end

  factory(:status_message, aliases: %i(status_message_without_participation)) do
    sequence(:text) {|n| "jimmy's #{n} whales" }
    author
    after(:build) do |sm|
      sm.diaspora_handle = sm.author.diaspora_handle
    end

    factory(:status_message_with_poll) do
      after(:build) do |sm|
        FactoryGirl.create(:poll, status_message: sm)
      end
    end

    factory(:status_message_with_location) do
      after(:build) do |sm|
        FactoryGirl.create(:location, status_message: sm)
      end
    end

    factory(:status_message_with_photo) do
      sequence(:text) {|n| "There are #{n} ninjas in this photo." }
      after(:build) do |sm|
        FactoryGirl.create(
          :photo,
          author:         sm.author,
          status_message: sm,
          pending:        false,
          public:         sm.public
        )
      end
    end

    factory(:status_message_in_aspect) do
      public false
      after(:build) do |sm|
        sm.author = FactoryGirl.create(:user_with_aspect).person
        sm.aspects << sm.author.owner.aspects.first
      end
    end

    factory(:status_message_with_participations) do
      transient do
        participants []
      end
      after(:build) do |sm, ev|
        ev.participants.each do |participant|
          person = participant.is_a?(User) ? participant.person : participant
          sm.participations.build(author: person)
        end
      end
    end
  end

  factory(:location) do
    address "Fernsehturm Berlin, Berlin, Germany"
    lat 52.520645
    lng 13.409779
  end

  factory(:poll) do
    sequence(:question) { |n| "What do you think about #{n} ninjas?" }
    after(:build) do |p|
      p.poll_answers << FactoryGirl.build(:poll_answer)
      p.poll_answers << FactoryGirl.build(:poll_answer)
    end
  end

  factory(:poll_answer) do
    sequence(:answer) { |n| "#{n} questionmarks" }
  end

  factory(:photo) do
    sequence(:random_string) {|n| SecureRandom.hex(10) }
    association :author, :factory => :person
    after(:build) do |p|
      p.unprocessed_image.store! File.open(File.join(File.dirname(__FILE__), 'fixtures', 'button.png'))
      p.update_remote_path
    end
  end

  factory(:remote_photo, :parent => :photo) do
    remote_photo_path 'https://photo.com/images/'
    remote_photo_name 'kittehs.jpg'
    association :author,:factory => :person
    processed_image nil
    unprocessed_image nil
  end

  factory :reshare do
    association(:root, :public => true, :factory => :status_message)
    association(:author, :factory => :person)
  end

  factory :invitation do
    service "email"
    identifier "bob.smith@smith.com"
    association :sender, :factory => :user_with_aspect
    after(:build) do |i|
      i.aspect = i.sender.aspects.first
    end
  end

  factory :invitation_code do
    sequence(:token){|n| "sdfsdsf#{n}"}
    association :user
    count 0
  end

  factory :service do |service|
    nickname "sirrobertking"
    type "Services::Twitter"

    sequence(:uid)           { |token| "00000#{token}" }
    sequence(:access_token)  { |token| "12345#{token}" }
    sequence(:access_secret) { |token| "98765#{token}" }
  end

  factory :service_user do
    sequence(:uid) { |id| "a#{id}"}
    sequence(:name) { |num| "Rob Fergus the #{num.ordinalize}" }
    association :service
    photo_url "/assets/user/adams.jpg"
  end

  factory :pod do
    sequence(:host) {|n| "pod#{n}.example#{r_str}.com" }
    ssl true
  end

  factory(:comment) do
    sequence(:text) {|n| "#{n} cats"}
    association(:author, :factory => :person)
    association(:post, :factory => :status_message)
  end

  factory(:notification) do
    association :recipient, :factory => :user
    association :target, :factory => :comment
    type 'Notifications::AlsoCommented'

    after(:build) do |note|
      note.actors << FactoryGirl.build(:person)
    end
  end

  factory(:tag, :class => ActsAsTaggableOn::Tag) do
    name "partytimeexcellent"
  end

  factory(:o_embed_cache) do
    url "http://youtube.com/kittens"
    data {{'data' => 'foo'}}
  end

  factory(:open_graph_cache) do
    url "http://example.com/articles/123"
    image "http://example.com/images/123.jpg"
    title "Some article"
    ob_type "article"
    description "This is the article lead"
  end

  factory(:tag_following) do
    association(:tag, :factory => :tag)
    association(:user, :factory => :user)
  end

  factory(:contact) do
    association(:person, :factory => :person)
    association(:user, :factory => :user)
  end

  factory(:mention) do
    association(:person, :factory => :person)
    association(:post, :factory => :status_message)
  end

  factory(:conversation) do
    association(:author, factory: :person)
    sequence(:subject) { |n| "conversation ##{n}" }

    after(:build) do |c|
      c.participants << c.author
    end
  end

  factory(:conversation_with_message, parent: :conversation) do
    after(:build) do |c|
      msg = FactoryGirl.build(:message)
      msg.conversation_id = c.id
      c.participants << msg.author
      msg.save
    end
  end

  factory(:message) do
    association(:author, factory: :person)
    sequence(:text) { |n| "message text ##{n}" }
  end

  factory(:message_with_conversation, parent: :message) do
    after(:build) do |msg|
      c = FactoryGirl.build(:conversation)
      c.participants << msg.author
      msg.conversation_id = c.id
    end
  end

  #templates
  factory(:status_with_photo_backdrop, :parent => :status_message_with_photo)

  factory(:photo_backdrop, :parent => :status_message_with_photo) do
    text ""
  end

  factory(:note, :parent => :status_message) do
    text SecureRandom.hex(1000)
  end

  factory(:status, :parent => :status_message)

  factory :o_auth_application, class: Api::OpenidConnect::OAuthApplication do
    client_name "Diaspora Test Client"
    redirect_uris %w(http://localhost:3000/)
  end

  factory :o_auth_application_with_image, class: Api::OpenidConnect::OAuthApplication do
    client_name "Diaspora Test Client"
    redirect_uris %w(http://localhost:3000/)
    logo_uri "/assets/user/default.png"
  end

  factory :o_auth_application_with_ppid, class: Api::OpenidConnect::OAuthApplication do
    client_name "Diaspora Test Client"
    redirect_uris %w(http://localhost:3000/)
    ppid true
    sector_identifier_uri "https://example.com/uri"
  end

  factory :o_auth_application_with_ppid_with_specific_id, class: Api::OpenidConnect::OAuthApplication do
    client_name "Diaspora Test Client"
    redirect_uris %w(http://localhost:3000/)
    ppid true
    sector_identifier_uri "https://example.com/uri"
  end

  factory :o_auth_application_with_multiple_redirects, class: Api::OpenidConnect::OAuthApplication do
    client_name "Diaspora Test Client"
    redirect_uris %w(http://localhost:3000/ http://localhost/)
  end

  factory :o_auth_application_with_xss, class: Api::OpenidConnect::OAuthApplication do
    client_name "<script>alert(0);</script>"
    redirect_uris %w(http://localhost:3000/)
  end

  factory :auth_with_read, class: Api::OpenidConnect::Authorization do
    o_auth_application
    user
    scopes %w(openid sub aud profile picture nickname name read)
  end

  factory :auth_with_read_and_ppid, class: Api::OpenidConnect::Authorization do
    association :o_auth_application, factory: :o_auth_application_with_ppid
    user
    scopes %w(openid sub aud profile picture nickname name read)
  end

  factory :auth_with_read_and_write, class: Api::OpenidConnect::Authorization do
    o_auth_application
    association :user, factory: :user_with_aspect
    scopes %w(openid sub aud profile picture nickname name read write)
  end

  # Factories for the DiasporaFederation-gem

  factory(:federation_person_from_webfinger, class: DiasporaFederation::Entities::Person) do
    sequence(:guid) { UUID.generate :compact }
    sequence(:diaspora_id) {|n| "bob-person-#{n}#{r_str}@example.net" }
    url AppConfig.pod_uri.to_s
    exported_key OpenSSL::PKey::RSA.generate(1024).public_key.export
    profile {
      DiasporaFederation::Entities::Profile.new(
        FactoryGirl.attributes_for(:federation_profile_from_hcard, diaspora_id: diaspora_id))
    }
  end

  factory(:federation_profile_from_hcard, class: DiasporaFederation::Entities::Profile) do
    sequence(:diaspora_id) {|n| "bob-person-#{n}#{r_str}@example.net" }
    sequence(:first_name) {|n| "My Name#{n}#{r_str}" }
    last_name nil
    image_url "/assets/user/default.png"
    image_url_medium "/assets/user/default.png"
    image_url_small "/assets/user/default.png"
    searchable true
  end

  factory :federation_profile_from_hcard_with_image_url, parent: :federation_profile_from_hcard do
    image_url "http://example.com/image.jpg"
    image_url_medium "http://example.com/image_mid.jpg"
    image_url_small "http://example.com/image_small.jpg"
  end
end
