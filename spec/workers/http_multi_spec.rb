require 'spec_helper'

describe Workers::HttpMulti do
  before :all do
    WebMock.disable_net_connect! allow_localhost: true
    WebMock::HttpLibAdapters::TyphoeusAdapter.disable!
    enable_typhoeus
  end
  after :all do
    disable_typhoeus
    WebMock.disable_net_connect!
  end

  before do
    @people = [FactoryGirl.create(:person), FactoryGirl.create(:person)]
    @post_xml = Base64.encode64 "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH"

    @hydra = Typhoeus::Hydra.new
    Typhoeus::Hydra.stub(:new).and_return(@hydra)
    @salmon = Salmon::EncryptedSlap.create_by_user_and_activity bob, Base64.decode64(@post_xml)
    Salmon::EncryptedSlap.stub(:create_by_user_and_activity).and_return @salmon
    @body = "encrypted things"
    @salmon.stub(:xml_for).and_return @body

    @response = Typhoeus::Response.new(
      code: 200,
      body: "",
      time: 0.2,
      effective_url: 'http://foobar.com',
      return_code: :ok
    )
    @failed_response = Typhoeus::Response.new(
      code: 504,
      body: "",
      time: 0.2,
      effective_url: 'http://foobar.com',
      return_code: :ok
    )
    @ssl_error_response = Typhoeus::Response.new(
      code: 0,
      body: "",
      time: 0.2,
      effective_url: 'http://foobar.com',
      return_code: :ssl_connect_error
    )
    @unable_to_resolve_response = Typhoeus::Response.new(
      code: 0,
      body: "",
      time: 0.2,
      effective_url: 'http://foobar.com',
      return_code: :couldnt_resolve_host
    )
  end

  it 'POSTs to more than one person' do
    @people.each do |person|
      Typhoeus.stub(person.receive_url).and_return @response
    end

    @hydra.should_receive(:queue).twice
    @hydra.should_receive(:run).once

    Workers::HttpMulti.new.perform bob.id, @post_xml, @people.map(&:id), "Postzord::Dispatcher::Private"
  end

  it 'retries' do
    person = @people.first

    Typhoeus.stub(person.receive_url).and_return @failed_response

    Workers::HttpMulti.should_receive(:perform_in).with(1.hour, bob.id, @post_xml, [person.id], anything, 1).once
    Workers::HttpMulti.new.perform bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private"
  end

  it 'retries if it could not resolve the server' do
    person = @people.first

    Typhoeus.stub(person.receive_url).and_return @unable_to_resolve_response

    Workers::HttpMulti.should_receive(:perform_in).with(1.hour, bob.id, @post_xml, [person.id], anything, 1).once
    Workers::HttpMulti.new.perform bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private"
  end

  it 'does not retry on an SSL error' do
    person = @people.first

    Typhoeus.stub(person.receive_url).and_return @ssl_error_response

    Workers::HttpMulti.should_not_receive(:perform_in)
    Workers::HttpMulti.new.perform bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private"
  end

  it 'max retries' do
    person = @people.first

    Typhoeus.stub(person.receive_url).and_return @failed_response

    Workers::HttpMulti.should_not_receive :perform_in
    Workers::HttpMulti.new.perform bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private", 3
  end

  it 'generates encrypted xml for people' do
    person = @people.first

    Typhoeus.stub(person.receive_url).and_return @response
    @salmon.should_receive(:xml_for).and_return @body

    Workers::HttpMulti.new.perform bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private"
  end

  it 'updates http users who have moved to https' do
    person = @people.first
    person.url = 'http://remote.net/'
    person.save

    response = Typhoeus::Response.new(
      code: 301,
      effective_url: 'https://foobar.com',
      response_headers: "Location: #{person.receive_url.sub('http://', 'https://')}",
      body: "",
      time: 0.2
    )
    Typhoeus.stub(person.receive_url).and_return response

    Workers::HttpMulti.new.perform bob.id, @post_xml, [person.id], "Postzord::Dispatcher::Private"
    person.reload
    person.url.should == "https://remote.net/"
  end

  it 'only sends to users with valid RSA keys' do
    person = @people.first
    person.serialized_public_key = "-----BEGIN RSA PUBLIC KEY-----\nPsych!\n-----END RSA PUBLIC KEY-----"
    person.save

    # Should be possible to drop when converting should_receive to expect(...).to
    RSpec::Mocks.proxy_for(Salmon::EncryptedSlap).reset

    Typhoeus.stub(person.receive_url).and_return @response
    Typhoeus.stub(@people[1].receive_url).and_return @response

    @hydra.should_receive(:queue).once
    Workers::HttpMulti.new.perform bob.id, @post_xml, @people.map(&:id), "Postzord::Dispatcher::Private"
  end
end
