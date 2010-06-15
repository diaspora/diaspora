#For Guidance
#http://github.com/thoughtbot/factory_girl
#http://railscasts.com/episodes/158-factories-not-fixtures
Factory.define :friend do |f|
  f.username 'max'
  f.url  'http://max.com/'
end

Factory.define :status_message do |m|
  m.sequence(:message) {|n| "jimmy's #{n} whales"}

end

Factory.define :user do |u|
  u.sequence(:email) {|n| "bob#{n}@aol.com"}
  u.password "bluepin7"
end

Factory.define :bookmark do |b|
  b.link "http://www.yahooligans.com/"
end
