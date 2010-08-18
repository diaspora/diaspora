require 'config/environment'

host = "localhost:3000"
url = "http://#{host}/"
# Create seed user
user = User.create!( :email => "tom@tom.joindiaspora.com",
                    :password => "evankorth",
                    :person => Person.new(
                      :email => "tom@tom.joindiaspora.com",
                      :url => url,
                      :profile => Profile.new( :first_name => "Alexander", :last_name => "Hamiltom" ))
                  )
user.person.save!

user2 = User.create!( :email => "korth@tom.joindiaspora.com",
                    :password => "evankorth",
                    :person => Person.new( :email => "korth@tom.joindiaspora.com",
                                          :url => url, 
                                          :profile => Profile.new( :first_name => "Evan",
                                                                  :last_name => "Korth")))

user2.person.save!

# friending users
group = user.group(:name => "other dudes")
request = user.send_friend_request_to(user2.receive_url, group.id)
reversed_request = user2.accept_friend_request( request.id, user2.group(:name => "presidents").id )
user.receive reversed_request.to_diaspora_xml
