#For Guidance
#http://github.com/thoughtbot/factory_girl
# http://railscasts.com/episodes/158-factories-not-fixtures
#This inclsion, because gpg-agent(not needed) is never run and hence never sets any env. variables on a MAC
ENV['GNUPGHOME'] = File.expand_path("../../gpg/diaspora-#{Rails.env}/", __FILE__)
GPGME::check_version({})

Factory.define :profile do |p|
  p.first_name "Robert"
  p.last_name "Grimm"
end

Factory.define :person do |p|
  p.email "bob-person@aol.com"
  p.active true
  p.sequence(:url)  {|n|"http://google-#{n}.com/"}
  p.key_fingerprint "fffffffffffffffffooooooooooooooo"
  p.profile Profile.new( :first_name => "Robert", :last_name => "Grimm" )
end

Factory.define :user do |u|
  u.sequence(:email) {|n| "bob#{n}@aol.com"}
  u.password "bluepin7"
  u.password_confirmation "bluepin7"
  u.url  "www.example.com/"
  u.key_fingerprint GPGME.list_keys("Smith", true).first.subkeys.first.fingerprint
  u.profile Profile.new( :first_name => "Bob", :last_name => "Smith" )
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
  p.image File.open( File.dirname(__FILE__) + '/fixtures/bp.jpeg')

end

Factory.define :author do |p|
  p.hub  "http://pubsubhubub.appspot.com/"
  p.service  "StatusNet"
  p.username  "danielgrippi"
  p.feed_url "http://google.com"
end
Factory.define(:comment) {}
