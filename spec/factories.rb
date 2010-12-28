#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures
#This inclsion, because gpg-agent(not needed) is never run and hence never sets any env. variables on a MAC

def r_str
  ActiveSupport::SecureRandom.hex(3)
end

Factory.define :profile do |p|
  p.sequence(:first_name) { |n| "Robert#{n}#{r_str}" }
  p.sequence(:last_name)  { |n| "Grimm#{n}#{r_str}" }
end


Factory.define :person do |p|
  p.sequence(:diaspora_handle) { |n| "bob-person-#{n}#{r_str}@aol.com" }
  p.sequence(:url)  { |n| "http://google-#{n}#{r_str}.com/" }
  p.profile Factory.create(:profile, :first_name => "eugene", :last_name => "weinstien")

  p.serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
end

Factory.define :user do |u|
  u.sequence(:username) { |n| "bob#{n}#{r_str}" }
  u.sequence(:email) { |n| "bob#{n}#{r_str}@pivotallabs.com" }
  u.password "bluepin7"
  u.password_confirmation { |u| u.password }
  u.serialized_private_key  OpenSSL::PKey::RSA.generate(1024).export
  u.after_build do |user|
  user.person = Factory.build(:person, :profile => Factory.create(:profile),
                              :owner_id => user._id,
                              :serialized_public_key => user.encryption_key.public_key.export,
                              :diaspora_handle => "#{user.username}@#{AppConfig[:pod_uri].host}")
  end
end

Factory.define :user_with_aspect, :parent => :user do |u|
  u.after_build { |user| user.aspects << Factory(:aspect) }
end

Factory.define :aspect do |aspect|
  aspect.name "generic"
end

Factory.define :status_message do |m|
  m.sequence(:message) { |n| "jimmy's #{n} whales" }
  m.person
end

Factory.define :photo do |p|
  p.image File.open( File.dirname(__FILE__) + '/fixtures/button.png')
end

Factory.define :service do |service|
  service.nickname "sirrobertking"
  service.provider "twitter"

  service.sequence(:uid)           { |token| "00000#{token}" }
  service.sequence(:access_token)  { |token| "12345#{token}" }
  service.sequence(:access_secret) { |token| "98765#{token}" }
  service.after_build do |s|
    s._type = "Services::#{s.provider.camelize}"
  end
end

Factory.define(:comment) {}

