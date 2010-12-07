require 'spec_helper'

describe Jobs::HttpMulti do
  
  let!(:user){ make_user }
  let!(:aspect){ user.aspects.create(:name => "awesome")}

  before do
    @people = [Factory(:person), Factory(:person)]
    @post = user.build_post(:status_message, :message => "hey", :to => [aspect])
    @post.save

    @post_type = @post.class.to_s

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
    Jobs::HttpMulti.perform(user.id, @post_type, @post.id, people_ids)
  end

  it 'retries' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@failed_response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Resque.should_receive(:enqueue).with(Jobs::HttpMulti, user.id, @post_type, @post.id, [person.id], 1).once
    Jobs::HttpMulti.perform(user.id, @post_type, @post.id, [person.id])
  end

  it 'max retries' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@failed_response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    Resque.should_not_receive(:enqueue)
    Jobs::HttpMulti.perform(user.id, @post_type, @post.id, [person.id], 3)
  end

  it 'generates salmon from user' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    user.should_receive(:salmon).with(@post).and_return(user.salmon(@post))
    Jobs::HttpMulti.perform(user.id, @post_type, @post.id, [person.id])
  end

  it 'generates encrypted xml for people' do
    person = @people[0]

    @hydra.stub(:post, person.receive_url).and_return(@response)

    Typhoeus::Hydra.stub!(:new).and_return(@hydra)

    salmon = user.salmon(@post)
    user.stub(:salmon).and_return(salmon)
    salmon.should_receive(:xml_for).and_return(salmon.xml_for(@post))

    Jobs::HttpMulti.perform(user.id, @post_type, @post.id, [person.id])
  end
end
