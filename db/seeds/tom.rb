require 'config/environment'

remote_url = "http://tom.joindiaspora.com/"
# Create seed user
user = User.instantiate!( :email => "tom@tom.joindiaspora.com",
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
                    :person => { :email => "korth@tom.joindiaspora.com",
                                          :url => remote_url, 
                                          :profile => { :first_name => "Evan",
                                                                  :last_name => "Korth",
                      :image_url => "http://tom.joindiaspora.com/images/user/korth.jpg"}})

user2.person.save!

# friending users
group = user.group(:name => "other dudes")
request = user.send_friend_request_to(user2.receive_url, group.id)
reversed_request = user2.accept_friend_request( request.id, user2.group(:name => "presidents").id )
user.receive reversed_request.to_diaspora_xml
user.group(:name => "Presidents")
