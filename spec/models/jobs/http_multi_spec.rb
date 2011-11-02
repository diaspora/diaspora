require 'spec_helper'

describe Jobs::HttpMulti do
  before :all do
    enable_typhoeus
  end
  after :all do
    disable_typhoeus
  end

  before do
    @people = [Factory(:person), Factory(:person)]
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
    response = Typhoeus::Response.new(:code => 301,:effective_url => 'https://foobar.com', :headers_hash => {"Location" => person.receive_url.sub('http://', 'https://')}, :body => "", :time => 0.2)
    @hydra.stub(:post, person.receive_url).and_return(response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    begin
      Jobs::HttpMulti.perform(bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private")
    rescue RuntimeError => e
      e.message == 'retry'
    end

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
