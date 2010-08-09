#This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => citie

require 'config/environment'

# Create seed user
user = User.create( :email => "tom@tom.joindiaspora.com",
                    :password => "evankorth",
                    :person => Person.new(
                      :email => "tom@tom.joindiaspora.com",
                      :url => "http://tom.joindiaspora.com/",
                      :profile => Profile.new( :first_name => "Alexander", :last_name => "Hamiltom" ))
                  )
user.person.save

user2 = User.create( :email => "korth@tom.joindiaspora.com",
                    :password => "evankorth",
                    :person => Person.new( :email => "korth@tom.joindiaspora.com",
                                          :url => "http://tom.joindiaspora.com/", 
                                          :profile => Profile.new( :first_name => "Evan",
                                                                  :last_name => "Korth")))
user2.person.save
