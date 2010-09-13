#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#



#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures
#This inclsion, because gpg-agent(not needed) is never run and hence never sets any env. variables on a MAC

Factory.define :profile do |p|
  p.first_name "Robert"
  p.last_name "Grimm"
end

Factory.define :person do |p|
  p.sequence(:email) {|n| "bob-person-#{n}@aol.com"}
  p.sequence(:url)  {|n| "http://google-#{n}.com/"}
  p.profile Factory.create(:profile)

  p.serialized_key OpenSSL::PKey::RSA.generate(1024).public_key.export
end

Factory.define :person_with_private_key, :parent => :person do |p|
  p.serialized_key OpenSSL::PKey::RSA.generate(1024).export
end

Factory.define :person_with_user, :parent => :person_with_private_key do |p|
end

Factory.define :user do |u|
  u.sequence(:username) {|n| "bob#{n}"}
  u.sequence(:email) {|n| "bob#{n}@aol.com"}
  u.password "bluepin7"
  u.password_confirmation "bluepin7"
  u.person { |a| Factory.create(:person_with_user, :owner_id => a._id)} 
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
