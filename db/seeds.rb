#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require Rails.root.join('config', 'environment')
require 'factory_girl_rails'
require Rails.root.join('spec', 'helper_methods')
include HelperMethods

alice = FactoryGirl.create(:user_with_aspect, :username => "alice", :password => 'evankorth')
bob   = FactoryGirl.create(:user_with_aspect, :username => "bob", :password => 'evankorth')
eve   = FactoryGirl.create(:user_with_aspect, :username => "eve", :password => 'evankorth')

def url_hash(name)
  image_url = "/assets/user/#{name}.jpg"
  {
    :image_url => image_url,
    :image_url_small => image_url,
    :image_url_medium => image_url
  }
end


print "Creating seeded users... "
alice.person.profile.update_attributes({:first_name => "Alice", :last_name => "Smith"}.merge(url_hash('uma')))
bob.person.profile.update_attributes({:first_name => "Bob", :last_name => "Grimm"}.merge(url_hash('wolf')))
eve.person.profile.update_attributes({:first_name => "Eve", :last_name => "Doe"}.merge(url_hash('angela')))
puts "done!"


print "Connecting users... "
connect_users(bob, bob.aspects.first, alice, alice.aspects.first)
connect_users(bob, bob.aspects.first, eve, eve.aspects.first)
puts "done!"

print "making Bob an admin... "
Role.add_admin(bob.person)
puts "done!"


require 'sidekiq/testing/inline'
require Rails.root.join('spec', 'support', 'user_methods')

print "Seeding post data..."
time_interval = 1000
(1..23).each do |n|
  [alice, bob, eve].each do |u|
    print '.'
    if(n%2==0)
      post = u.post :status_message, :text => "#{u.username} - #{n} - #seeded", :to => u.aspects.first.id
    else
      post = u.post(:reshare, :root_guid => FactoryGirl.create(:status_message, :public => true).guid, :to => 'all')
    end

    post.created_at = post.created_at - time_interval
    post.updated_at = post.updated_at - time_interval
    post.save
    time_interval += 1000
  end
end
puts " done!"

puts "Successfully seeded the db with users eve, bob, and alice (password: 'evankorth')"
puts ""
