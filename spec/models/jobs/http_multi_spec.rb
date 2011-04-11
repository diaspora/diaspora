require 'spec_helper'

describe Job::HttpMulti do
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
    @response = Typhoeus::Response.new(:code => 200, :headers => "", :body => "", :time => 0.2)
    @failed_response = Typhoeus::Response.new(:code => 504, :headers => "", :body => "", :time => 0.2)
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

    salmon = Salmon::SalmonSlap.create(bob, Base64.decode64(@post_xml))
    Salmon::SalmonSlap.stub(:create).and_return(salmon)
    salmon.should_receive(:xml_for).and_return("encrypted things")

    Job::HttpMulti.perform(bob.id, @post_xml, [person.id])
  end

  it 'updates http users who have moved to https' do
    person = @people.first
    person.url = 'http://remote.net/'
    person.save
    response = Typhoeus::Response.new(:code => 301, :headers_hash => {"Location" => person.receive_url.sub('http://', 'https://')}, :body => "", :time => 0.2)
    @hydra.stub(:post, person.receive_url).and_return(response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Job::HttpMulti.perform(bob.id, @post_xml, [person.id])
    person.reload
    person.url.should == "https://remote.net/"
  end
end
