# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

# Create seed user
user = User.create(  :password => "evankorth", 
                  :person => Person.create(
                    :email => "robert@joindiaspora.com",
                    :url => "http://localhost:3000/",
                    :profile => Profile.new( 
                      :first_name => "bobert", 
                      :last_name => "brin" )))

puts user.save!
puts user.person.save
puts user.save!
puts user.person.inspect
puts user.inspect
