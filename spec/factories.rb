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

  p.serialized_public_key OpenSSL::PKey::RSA.generate(1024).public_key.export
end

Factory.define :album do |p|
  p.name "my first album"
  p.person { |a| Factory.create(:person) }
end

Factory.define :user do |u|
  u.sequence(:username) {|n| "bob#{n}"}
  u.sequence(:email) {|n| "bob#{n}@pivotallabs.com"}
  u.password "bluepin7"
  u.password_confirmation "bluepin7"
  u.serialized_private_key  OpenSSL::PKey::RSA.generate(1024).export
  u.after_build do |user|
    user.person = Factory(:person, :owner_id => user._id,
                          :serialized_public_key => user.encryption_key.public_key.export,
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

Factory.define :fb_status do |s|
   s.graph_id "367501354973"
   s.author_name "Bret Taylor"
   s.author_id "220439"
   s.message "Pigs run from our house in fear. Tonight, I am wrapping the pork tenderloin in bacon and putting pancetta in the corn."
   s.updated_time Time.parse "2010-03-06T02:57:48+0000"
end
