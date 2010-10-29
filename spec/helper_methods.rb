module HelperMethods
  def stub_sockets
    Diaspora::WebSocket.stub!(:queue_to_user).and_return(true)
    Diaspora::WebSocket.stub!(:subscribe).and_return(true)
    Diaspora::WebSocket.stub!(:unsubscribe).and_return(true)
  end

  def unstub_sockets
    Diaspora::WebSocket.unstub!(:queue_to_user)
    Diaspora::WebSocket.unstub!(:subscribe)
    Diaspora::WebSocket.unstub!(:unsubscribe)
  end

  def stub_comment_signature_verification
    Comment.any_instance.stubs(:verify_signature).returns(true)
  end

  def unstub_mocha_stubs
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def get_models
    models = []
    Dir.glob( File.dirname(__FILE__) + '/../app/models/*' ).each do |f|
      models << File.basename( f ).gsub( /^(.+).rb/, '\1')
    end
    models
  end

  def message_queue
    User::QUEUE
  end

  def friend_users(user1, aspect1, user2, aspect2)
    request = user1.send_friend_request_to(user2.person, aspect1)
    user2.receive_friend_request(request)
    reversed_request = user2.accept_friend_request( request.id, aspect2.id)
    user1.reload
    user1.receive reversed_request.to_diaspora_xml, user2.person
    user1.reload
    aspect1.reload
    user2.reload
    aspect2.reload
  end

  def stub_success(address = 'abc@example.com', opts = {})
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    if opts[:diaspora] || host.include?("diaspora")
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => finger_xrd)
      stub_request(:get, "http://#{host}/hcard/users/4c8eccce34b7da59ff000002").to_return(:status => 200, :body => hcard_response)
    else
      stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 200, :body => nonseed_finger_xrd)
      stub_request(:get, 'http://evan.status.net/hcard').to_return(:status => 200, :body => evan_hcard)
    end
  end

  def stub_failure(address = 'abc@example.com')
    host = address.split('@')[1]
    stub_request(:get, "https://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, "http://#{host}/.well-known/host-meta").to_return(:status => 200, :body => host_xrd)
    stub_request(:get, /webfinger\/\?q=#{address}/).to_return(:status => 500)
  end

  def host_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/host_xrd').read
  end

  def finger_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/finger_xrd').read
  end

  def hcard_response
    File.open(File.dirname(__FILE__) + '/fixtures/hcard_response').read
  end

  def nonseed_finger_xrd
    File.open(File.dirname(__FILE__) + '/fixtures/nonseed_finger_xrd').read
  end

  def evan_hcard
    File.open(File.dirname(__FILE__) + '/fixtures/evan_hcard').read
  end

  def build_user_fixtures
    arr = []
    10.times do
      user = Factory :user
      person = user.person
      arr << { :user => user.to_mongo, :person => person.to_mongo}
    end
    arr
  end

  def regenerate_user_fixtures
    users = {:users => build_user_fixtures}
    File.open(File.join(Rails.root,"spec/fixtures/users.yaml"),'w') do |file|
      file.write(users.to_yaml)
    end
  end

  def save_user_fixtures
    yaml_users = YAML.load_file(File.join(Rails.root,"spec/fixtures/users.yaml"))
    db = MongoMapper.database
    people = db.collection("people")
    users = db.collection("users")
    yaml_users[:users].each do |yaml_user|
      user = yaml_user[:user]
      person = yaml_user[:person]
      users.insert(user)
      people.insert(person)
    end
  end
end
