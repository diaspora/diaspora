#   Copyright (c) 2010, Disapora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.



require 'config/environment'

host = "localhost:3000"
url = "http://#{host}/"
# Create seed user
user = User.instantiate!( :email => "tom@tom.joindiaspora.com",
                     :username => "tom",
                    :password => "evankorth",
                    :password_confirmation => "evankorth",
                    :url=> "http://#{username}.joindiaspora.com/"
                    :person => Person.new(
                      :diaspora_handle => "tom@tom.joindiaspora.com",
                      :url => url,
                      :profile => Profile.new( :first_name => "Alexander", :last_name => "Hamiltom" ))
                  )
user.person.save!

user2 = User.instantiate!( :email => "korth@tom.joindiaspora.com",
                     :username => "korth",
                     :url=> "http://#{username}.joindiaspora.com/"
                    :password => "evankorth",
                    :password_confirmation => "evankorth",
                    :person => Person.new( :diaspora_handle => "korth@tom.joindiaspora.com",
                                          :url => url, 
                                          :profile => Profile.new( :first_name => "Evan",
                                                                  :last_name => "Korth")))

user2.person.save!

# friending users
aspect = user.aspect(:name => "other dudes")
request = user.send_friend_request_to(user2, aspect)
reversed_request = user2.accept_friend_request( request.id, user2.aspect(:name => "presidents").id )
user.receive reversed_request.to_diaspora_xml
