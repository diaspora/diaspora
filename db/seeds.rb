#   Copyright (c) 2010, Diaspora Inc.  This file is
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

alice = Factory(:user_with_aspect, :username => "alice", :password => 'evankorth', :invites => 10)
bob   = Factory(:user_with_aspect, :username => "bob", :password => 'evankorth', :invites => 10)
eve   = Factory(:user_with_aspect, :username => "eve", :password => 'evankorth', :invites => 10)

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

connect_users(bob, bob.aspects.first, alice, alice.aspects.first)
connect_users(bob, bob.aspects.first, eve, eve.aspects.first)

# Uncomment these and return out of Service::Facebook#save_friends 
#service = Service.new(:user_id => bob.id)
#service.type = "Services::Facebook"
#service.access_token = "abc123"
#service.save!
#su = ServiceUser.create!(:service_id => service.id, :photo_url => "/images/user/angela.jpg", :uid => "abc123", :name => "Angelica")

require 'spec/support/fake_resque'
require 'spec/support/fake_redis'
require 'spec/support/user_methods'
time_interval = 1000
(1..25).each do |n|
  [alice, bob, eve].each do |u|
    post = u.post :status_message, :text => "#{u.username} - #{n} - #seeded", :to => u.aspects.first.id
    post.created_at = post.created_at - time_interval
    post.updated_at = post.updated_at - time_interval
    post.save
    time_interval += 1000
  end
end
