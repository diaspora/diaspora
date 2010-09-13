require 'config/environment'

remote_url = "http://tom.joindiaspora.com/"
# Create seed user
user = User.instantiate!( :email => "tom@tom.joindiaspora.com",
                     :username => "tom",
                    :password => "evankorth",
                    :person => {
                      :email => "tom@tom.joindiaspora.com",
                      :url => remote_url,
                      :profile => { :first_name => "Alexander", :last_name => "Hamiltom",
                      :image_url => "http://tom.joindiaspora.com/images/user/tom.jpg"}}
                  )
user.person.save!

user2 = User.instantiate!( :email => "korth@tom.joindiaspora.com",
                    :password => "evankorth",
                     :username => "korth",
                    :person => { :email => "korth@tom.joindiaspora.com",
                                          :url => remote_url, 
                                          :profile => { :first_name => "Evan",
                                                                  :last_name => "Korth",
                      :image_url => "http://tom.joindiaspora.com/images/user/korth.jpg"}})

user2.person.save!

# friending users
aspect = user.aspect(:name => "other dudes")
request = user.send_friend_request_to(user2, aspect)
reversed_request = user2.accept_friend_request( request.id, user2.aspect(:name => "presidents").id )
user.receive reversed_request.to_diaspora_xml
user.aspect(:name => "Presidents")
