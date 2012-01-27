#   Copyright (c) 2010-2011, Diaspora In  This file is
#   licensed under the Affero General Public License version 3 or late  See
#   the COPYRIGHT file.

#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures

def r_str
  ActiveSupport::SecureRandom.hex(3)
end

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

  factory :person do
    sequence(:diaspora_handle) { |n| "bob-person-#{n}#{r_str}@example.net" }
    sequence(:url)  { |n| AppConfig[:pod_url] }
    serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
    after_build do |person|
      person.profile = Factory.build(:profile, :person => person) unless person.profile.first_name.present?
    end
    after_create do |person|
      person.profile.save
    end
  end

  factory :account_deletion do
    association :person
    after_build do |delete|
      delete.diaspora_handle = delete.person.diaspora_handle
    end
  end

  factory :searchable_person, :parent => :person do
    after_build do |person|
      person.profile = Factory.build(:profile, :person => person, :searchable => true)
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
    after_build do |u|
      u.person = Factory.build(:person, :profile => Factory.build(:profile),
                                  :owner_id => u.id,
                                  :serialized_public_key => u.encryption_key.public_key.export,
                                  :diaspora_handle => "#{u.username}#{User.diaspora_id_host}")
    end
    after_create do |u|
      u.person.save
      u.person.profile.save
    end
  end

  factory :user_with_aspect, :parent => :user do
    after_create { |u| Factory(:aspect, :user => u) }
  end

  factory :aspect do
    name "generic"
    association :user
  end

  factory(:status_message) do
    sequence(:text) { |n| "jimmy's #{n} whales" }
    association :author, :factory => :person
    after_build do |sm|
      sm.diaspora_handle = sm.author.diaspora_handle
    end
  end

  factory(:status_message_with_photo, :parent => :status_message) do
    sequence(:text) { |n| "There are #{n} ninjas in this photo." }
    after_build do |sm|
      Factory(:photo, :author => sm.author, :status_message => sm, :pending => false, :public => public)
    end
  end

  factory(:photo) do
    sequence(:random_string) {|n| ActiveSupport::SecureRandom.hex(10) }
    association :author, :factory => :person
    after_build do |p|
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
    after_build do |i|
      i.aspect = i.sender.aspects.first
    end
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
    photo_url "/images/user/adams.jpg"
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

    after_build do |note|
      note.actors << Factory.build(:person)
    end
  end

  factory(:activity_streams_photo, :class => ActivityStreams::Photo) do
    association(:author, :factory => :person)
    image_url "#{AppConfig[:pod_url]}/images/asterisk.png"
    image_height 154
    image_width 154
    object_url "http://example.com/awesome_things.gif"
    objectId "http://example.com/awesome_things.gif"
    actor_url "http://notcubbes/cubber"
    provider_display_name "not cubbies"
    public true
  end

  factory(:app, :class => OAuth2::Provider.client_class) do
    sequence(:name) { |token| "Chubbies#{token}" }
    sequence(:application_base_url) { |token| "http://chubbi#{token}.es/" }

    description "The best way to chub on the ne"
    icon_url "/images/chubbies48.png"
    permissions_overview "I will use the permissions this way!"
    sequence(:public_key) {|n| OpenSSL::PKey::RSA.new(2048) }
  end

  factory(:oauth_authorization, :class => OAuth2::Provider.authorization_class) do
    association(:client, :factory => :app)
    association(:resource_owner, :factory => :user)
  end

  factory(:oauth_access_token, :class => OAuth2::Provider.access_token_class) do
    association(:authorization, :factory => :oauth_authorization)
  end

  factory(:tag, :class => ActsAsTaggableOn::Tag) do
    name "partytimeexcellent"
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
end
