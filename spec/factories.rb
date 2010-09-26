#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures
#This inclsion, because gpg-agent(not needed) is never run and hence never sets any env. variables on a MAC

Factory.define :profile do |p|
  p.first_name "Robert"
  p.last_name "Grimm"
end

Factory.define :person do |p|
  p.sequence(:diaspora_handle) {|n| "bob-person-#{n}@aol.com"}
  p.sequence(:url)  {|n| "http://google-#{n}.com/"}
  p.profile Factory.create(:profile)

  p.serialized_key OpenSSL::PKey::RSA.generate(1024).public_key.export
end

Factory.define :album do |p|
  p.name "my first album"
  p.person { |a| Factory.create(:person) }
end

Factory.define :person_with_private_key, :parent => :person do |p|
  p.serialized_key OpenSSL::PKey::RSA.generate(1024).export
end

Factory.define :person_with_user, :parent => :person_with_private_key do |p|
end

Factory.define :user do |u|
  u.sequence(:username) {|n| "bob#{n}"}
  u.sequence(:email) {|n| "bob#{n}@pivotallabs.com"}
  u.password "bluepin7"
  u.password_confirmation "bluepin7"
  u.after_build do |user|
    user.person = Factory(:person_with_private_key, :owner_id => user._id,
                          :diaspora_handle => "#{user.username}@#{APP_CONFIG[:pod_url].gsub(/(https?:|www\.)\/\//, '').chop!}")
  end
end

Factory.define :user_with_aspect, :parent => :user do |u|
  u.after_build { |user| user.aspects << Factory(:aspect) }
end

Factory.define :aspect do |aspect|
  aspect.name "generic"
end

Factory.define :status_message do |m|
  m.sequence(:message) {|n| "jimmy's #{n} whales"}
  m.person
end

Factory.define :blog do |b|
  b.sequence(:title) {|n| "bobby's #{n} penguins"}
  b.sequence(:body) {|n| "jimmy's huge #{n} whales"}
end

Factory.define :bookmark do |b|
  b.link "http://www.yahooligans.com/"
end

Factory.define :post do |p|
end

Factory.define :photo do |p|
  p.image File.open( File.dirname(__FILE__) + '/fixtures/button.png')

end

Factory.define(:comment) {}
