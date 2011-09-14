#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


require 'lib/hydra_wrapper'

describe HydraWrapper do

  context 'intergration' do
    pending
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
      Job::HttpMulti.perform(bob.id, @post_xml, people_ids)
    end

    it 'retries' do
      person = @people[0]

      @hydra.stub(:post, person.receive_url).and_return(@failed_response)

      Typhoeus::Hydra.stub!(:new).and_return(@hydra)

      Resque.should_receive(:enqueue).with(Job::HttpMulti, bob.id, @post_xml, [person.id], 1).once
      Job::HttpMulti.perform(bob.id, @post_xml, [person.id])
    end

    it 'max retries' do
      person = @people[0]

      @hydra.stub(:post, person.receive_url).and_return(@failed_response)

      Typhoeus::Hydra.stub!(:new).and_return(@hydra)

      Resque.should_not_receive(:enqueue)
      Job::HttpMulti.perform(bob.id, @post_xml, [person.id], 3)
    end

    it 'generates encrypted xml for people' do
      person = @people[0]

      @hydra.stub(:post, person.receive_url).and_return(@response)

      Typhoeus::Hydra.stub!(:new).and_return(@hydra)

      salmon = Salmon::EncryptedSlap.create_by_user_and_activity(bob, Base64.decode64(@post_xml))
      Salmon::EncryptedSlap.stub(:create_by_user_and_activity).and_return(salmon)
      salmon.should_receive(:xml_for).and_return("encrypted things")

      Job::HttpMulti.perform(bob.id, @post_xml, [person.id])
    end

    it 'updates http users who have moved to https' do
      person = @people.first
      person.url = 'http://remote.net/'
      person.save
      response = Typhoeus::Response.new(:code => 301,:effective_url => 'https://foobar.com', :headers_hash => {"Location" => person.receive_url.sub('http://', 'https://')}, :body => "", :time => 0.2)
      @hydra.stub(:post, person.receive_url).and_return(response)

      Typhoeus::Hydra.stub!(:new).and_return(@hydra)

      Job::HttpMulti.perform(bob.id, @post_xml, [person.id])
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
      Job::HttpMulti.perform(bob.id, @post_xml, [@people[0].id, @people[1].id])
    end
  end


  ###############

  before do
    @wrapper = HydraWrapper.new(stub, [stub, stub, stub], stub, stub)
  end

  describe 'initialize' do
    it 'it sets the proper instance variables' do
      user = "user"
      people = ["person"]
      encoded_object_xml = "encoded xml"
      dispatcher_class = "Postzord::Dispatcher::Private"

      wrapper = HydraWrapper.new(user, people, encoded_object_xml, dispatcher_class)
      wrapper.user.should == user
      wrapper.people.should == people
      wrapper.encoded_object_xml.should == encoded_object_xml
    end
  end

  describe '#run' do
    it 'delegates #run to the @hydra' do
      @wrapper.hydra = stub.as_null_object
      @wrapper.hydra.should_receive(:run)
      @wrapper.run
    end
  end

  describe '#salmon' do
    it 'calls the salmon method on the dispatcher class (and memoizes)' do
      @wrapper.dispatcher_class.should_receive(:salmon).once.and_return(true)
      @wrapper.salmon
      @wrapper.salmon
    end
  end

  describe '#grouped_people' do
    it 'groups people given their receive_urls' do
      @wrapper.people.each do |person|
        @wrapper.dispatcher_class.should_receive(:receive_url_for).with(person).and_return("foo.com")
      end
      @wrapper.grouped_people.should == {"foo.com" => @wrapper.people}
    end
  end

  describe '#enqueue_batch' do
    it 'calls #grouped_people' do
      @wrapper.should_receive(:grouped_people).and_return([])
      @wrapper.enqueue_batch
    end

    it 'inserts a job for every group of people' do
      @wrapper.dispatcher_class = stub(:salmon => stub(:xml_for => "<XML>"))
      @wrapper.stub(:grouped_people).and_return({'https://foo.com' => @wrapper.people})
      @wrapper.people.should_receive(:first).once
      @wrapper.should_receive(:insert_job).with('https://foo.com', "<XML>", @wrapper.people).once
      @wrapper.enqueue_batch
    end

    it 'does not insert a job for a person whos xml returns false' do
      @wrapper.stub(:grouped_people).and_return({'https://foo.com' => [stub]})
      @wrapper.dispatcher_class = stub(:salmon => stub(:xml_for => false))
      @wrapper.should_not_receive(:insert_job)
      @wrapper.enqueue_batch
    end

  end

  describe '#insert_job' do
    it 'creates a new request object'
    it 'calls #prepare_request! on a new request object'
    it 'adds request to the hydra queue'
  end

  describe '#prepare_request!' do
    it 'calls Pod.find_or_create_by_url'
    it 'calls Person.url_batch_update'
  end

  describe '#redirecting_to_https?!' do
    it 'does not execute unless response has a 3xx code' do
      resp = stub(:code => 200)
      @wrapper.redirecting_to_https?(resp).should be_false
    end

    it "returns true if just the protocol is different" do
      host = "the-same.com/"
      resp = stub(:request => stub(:url => "http://#{host}"), :code => 302, :headers_hash => {'Location' => "https://#{host}"})

      @wrapper.redirecting_to_https?(resp).should be_true
    end

    it "returns false if not just the protocol is different" do
      host = "the-same.com/"
      resp = stub(:request => stub(:url => "http://#{host}"), :code => 302, :headers_hash => {'Location' => "https://not-the-same/"})

      @wrapper.redirecting_to_https?(resp).should be_false
    end
  end
end
