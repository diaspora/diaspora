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

require File.join(File.dirname(__FILE__), "..", "config", "environment")
require 'factory_girl_rails'
require File.join(File.dirname(__FILE__), "..", "spec", "helper_methods")
include HelperMethods

alice = Factory(:user_with_aspect, :username => "alice", :password => 'evankorth')
bob   = Factory(:user_with_aspect, :username => "bob", :password => 'evankorth')
eve   = Factory(:user_with_aspect, :username => "eve", :password => 'evankorth')

print "Creating seeded users... "
alice.person.profile.update_attributes(:first_name => "Alice", :last_name => "Smith",
  :image_url => "/images/user/uma.jpg",
  :image_url_small => "/images/user/uma.jpg",
  :image_url_medium => "/images/user/uma.jpg")
bob.person.profile.update_attributes(:first_name => "Bob", :last_name => "Grimm",
  :image_url => "/images/user/wolf.jpg",
  :image_url_small => "/images/user/wolf.jpg",
  :image_url_medium => "/images/user/wolf.jpg")
eve.person.profile.update_attributes(:first_name => "Eve", :last_name => "Doe",
  :image_url => "/images/user/angela.jpg",
  :image_url_small => "/images/user/angela.jpg",
  :image_url_medium => "/images/user/angela.jpg")
puts "done!"

print "Connecting users... "
connect_users(bob, bob.aspects.first, alice, alice.aspects.first)
connect_users(bob, bob.aspects.first, eve, eve.aspects.first)
puts "done!"

print "Adding Facebook contacts... "
bob_facebook = Factory(:service, :type => 'Services::Facebook', :user_id => bob.id, :uid => bob.username)
ServiceUser.import((1..40).map{|n| Factory.build(:service_user, :service => bob_facebook)} +
                   [Factory.build(:service_user, :service => bob_facebook, :uid => eve.username, :person => eve.person,
                                 :contact => bob.contact_for(eve.person))])

eve_facebook = Factory(:service, :type => 'Services::Facebook', :user_id => eve.id, :uid => eve.username)
ServiceUser.import((1..40).map{|n| Factory.build(:service_user, :service => eve_facebook) } +
                   [Factory.build(:service_user, :service => eve_facebook, :uid => bob.username, :person => bob.person,
                                  :contact => eve.contact_for(bob.person))])


puts "done!"

require 'spec/support/fake_resque'
require 'spec/support/fake_redis'
require 'spec/support/user_methods'

old_cache_setting = AppConfig[:redis_cache]
AppConfig[:redis_cache] = false

print "Seeding post data..."
time_interval = 1000
(1..25).each do |n|
  [alice, bob, eve].each do |u|
    print '.'
    if(n%3==1)
      post = u.post :status_message, :text => "#{u.username} - #{n} - #seeded", :to => u.aspects.first.id
    elsif(n%3==2)
      post =u.post(:reshare, :root_guid => Factory(:status_message, :public => true).guid, :to => 'all')
    else
      post = Factory(:activity_streams_photo, :public => true, :author => u.person)
      u.add_to_streams(post, u.aspects)
    end

    post.created_at = post.created_at - time_interval
    post.updated_at = post.updated_at - time_interval
    post.save
    time_interval += 1000
  end
end
puts " done!"

AppConfig[:redis_cache] = old_cache_setting

puts "Successfully seeded the db with users eve, bob, and alice (password: 'evankorth')"
puts ""

