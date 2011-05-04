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

alice.person.profile.update_attributes(:first_name => "Alice", :last_name => "Smith")
bob.person.profile.update_attributes(:first_name => "Bob", :last_name => "Grimm")
eve.person.profile.update_attributes(:first_name => "Eve", :last_name => "Doe")

connect_users(bob, bob.aspects.first, alice, alice.aspects.first)
connect_users(bob, bob.aspects.first, eve, eve.aspects.first)


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
