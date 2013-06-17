require 'spec_helper'
require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Person do
  before do
    @stream = Stream::Person.new(alice, bob.person, :max_time => Time.now, :order => 'updated_at')
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  it "returns the most recent posts" do
    pending # this randomly fails on postgres
    posts = []
    fetched_posts = []
    
    aspect = bob.aspects.first.id
    Timecop.scale(600) do
      16.times do |n|
        posts << bob.post(:status_message, text: "hello#{n}", to: aspect)
        posts << bob.post(:status_message, text: "hello#{n}", public: true)
      end

      fetched_posts = Stream::Person.new(alice, bob.person).stream_posts
    end

    posts = posts.reverse.slice(0..14)
    fetched_posts = fetched_posts.slice(0..14)

    fetched_posts.should == posts
  end

end
