#For Guidance
#http://github.com/thoughtbot/factory_girl
#http://railscasts.com/episodes/158-factories-not-fixtures

Factory.define :friend do |f|
  f.real_name 'John Doe'
  f.email 'max@max.com'
  f.url  'http://max.com/'
end

Factory.define :status_message do |m|
  m.sequence(:message) {|n| "jimmy's #{n} whales"}
end

Factory.define :blog do |b|
  b.sequence(:title) {|n| "bobby's #{n} penguins"}
  b.sequence(:body) {|n| "jimmy's huge #{n} whales"}
end

Factory.define :user do |u|
  u.real_name 'Bob Smith'
  u.sequence(:email) {|n| "bob#{n}@aol.com"}
  u.password "bluepin7"
  u.password_confirmation "bluepin7"
end

Factory.define :bookmark do |b|
  b.link "http://www.yahooligans.com/"
end

Factory.define :post do |p|
  p.source "New York Times"
  p.sequence(:snippet) {|n| "This is some information #{n}"}
end
