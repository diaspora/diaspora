require 'spec_helper'

describe Jobs::HttpMulti do
  before :all do
    WebMock.disable_net_connect!(:allow_localhost => true)
    enable_typhoeus
  end
  after :all do
    disable_typhoeus
    WebMock.disable_net_connect!
  end

  before do
    @people = [FactoryGirl.create(:person), FactoryGirl.create(:person)]
    @post_xml = Base64.encode64("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH")

    @hydra = Typhoeus::Hydra.new
    @response = Typhoeus::Response.new(:code => 200, :headers => "", :body => "", :time => 0.2, :effective_url => 'http://foobar.com')
    @failed_response = Typhoeus::Response.new(:code => 504, :headers => "", :body => "", :time => 0.2, :effective_url => 'http://foobar.com')
  end

  it 'POSTs to more than one person' do
    @people.each do |person|
      @hydra.stub(:post, person.receive_url).and_return(@response)
    end

    @hydra.should_receive(:queue).twice
    @hydra.should_receive(:run).once
    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    people_ids = @people.map{ |p| p.id }
    Jobs::HttpMulti.perform(bob.id, @post_xml, people_ids, "Postzord::Dispatcher::Private")
  end

  it 'retries' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@failed_response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Resque.should_receive(:enqueue).with(Jobs::HttpMulti, bob.id, @post_xml, [person.id], anything, 1).once
    Jobs::HttpMulti.perform(bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private")
  end

  it 'max retries' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@failed_response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Resque.should_not_receive(:enqueue)
    Jobs::HttpMulti.perform(bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private", 3)
  end

  it 'generates encrypted xml for people' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    salmon = Salmon::EncryptedSlap.create_by_user_and_activity(bob, Base64.decode64(@post_xml))
    Salmon::EncryptedSlap.stub(:create_by_user_and_activity).and_return(salmon)
    salmon.should_receive(:xml_for).and_return("encrypted things")

    Jobs::HttpMulti.perform(bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private")
  end

  it 'updates http users who have moved to https' do
    person = @people.first
    person.url = 'http://remote.net/'
    person.save

    stub_request(:post, person.receive_url).to_return(:status=>200, :body=>"", :headers=>{})
    response = Typhoeus::Response.new(:code => 301,:effective_url => 'https://foobar.com', :headers_hash => {"Location" => person.receive_url.sub('http://', 'https://')}, :body => "", :time => 0.2)
    @hydra.stub(:post, person.receive_url).and_return(response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Jobs::HttpMulti.perform(bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private")
    person.reload
    person.url.should == "https://remote.net/"
  end

  it 'only sends to users with valid RSA keys' do
    person = @people[0]
    person.serialized_public_key = "-----BEGIN RSA PUBLIC KEY-----\nPsych!\n-----END RSA PUBLIC KEY-----"
    person.save

    @hydra.stub(:post, @people[0].receive_url).and_return(@response)
    @hydra.stub(:post, @people[1].receive_url).and_return(@response)
    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    @hydra.should_receive(:queue).once
    Jobs::HttpMulti.perform(bob.id, @post_xml, [@people[0].id, @people[1].id], "Postzord::Dispatcher::Private")
  end
end
