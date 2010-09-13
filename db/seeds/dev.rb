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



require 'config/environment'

host = "localhost:3000"
url = "http://#{host}/"
# Create seed user
user = User.instantiate!( :email => "tom@tom.joindiaspora.com",
                     :username => "tom",
                    :password => "evankorth",
                    :person => Person.new(
                      :email => "tom@tom.joindiaspora.com",
                      :url => url,
                      :profile => Profile.new( :first_name => "Alexander", :last_name => "Hamiltom" ))
                  )
user.person.save!

user2 = User.instantiate!( :email => "korth@tom.joindiaspora.com",
                     :username => "korth",
                    :password => "evankorth",
                    :person => Person.new( :email => "korth@tom.joindiaspora.com",
                                          :url => url, 
                                          :profile => Profile.new( :first_name => "Evan",
                                                                  :last_name => "Korth")))

user2.person.save!

# friending users
aspect = user.aspect(:name => "other dudes")
request = user.send_friend_request_to(user2, aspect)
reversed_request = user2.accept_friend_request( request.id, user2.aspect(:name => "presidents").id )
user.receive reversed_request.to_diaspora_xml
