require 'spec_helper'
require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Multi do
  before do
    @stream = Stream::Multi.new(alice, :max_time => Time.now, :order => 'updated_at')
  end

  describe 'shared behaviors' do
    it_should_behave_like 'it is a stream'
  end

  describe "#posts" do
    it "calls EvilQuery::MultiStream with correct parameters" do
      ::EvilQuery::MultiStream.should_receive(:new)
        .with(alice, 'updated_at', @stream.max_time,
              AppConfig.settings.community_spotlight.enable? &&
              alice.show_community_spotlight_in_stream?)
        .and_return(double.tap { |m| m.stub(:make_relation!)})
      @stream.posts
    end
  end

  describe '#publisher_opts' do
    it 'prefills, sets public, and autoexpands if welcome? is set' do
      prefill_text = "sup?"
      @stream.stub(:welcome?).and_return(true)
      @stream.stub(:publisher_prefill).and_return(prefill_text)
      @stream.send(:publisher_opts).should == {:open => true,
                                               :prefill => prefill_text,
                                               :public => true}
    end

    it 'provides no opts if welcome? is not set' do
      prefill_text = "sup?"
      @stream.stub(:welcome?).and_return(false)
      @stream.send(:publisher_opts).should == {}
    end
  end

  describe "#publisher_prefill" do
    before do
      @tag = ActsAsTaggableOn::Tag.find_or_create_by(name: "cats")
      @tag_following = alice.tag_followings.create(:tag_id => @tag.id)

      @stream = Stream::Multi.new(alice)
    end

    it 'returns includes new user hashtag' do
      @stream.send(:publisher_prefill).should match(/#NewHere/i)
    end

    it 'includes followed hashtags' do
      @stream.send(:publisher_prefill).should include("#cats")
    end

    context 'when invited by another user' do
      before do
        @user = FactoryGirl.create(:user, :invited_by => alice)
        @inviter = alice.person

        @stream = Stream::Multi.new(@user)
      end

      it 'includes a mention of the inviter' do
        mention = "@{#{@inviter.name} ; #{@inviter.diaspora_handle}}"
        @stream.send(:publisher_prefill).should include(mention)
      end
    end
  end

  describe "#welcome?" do
    before do
      @stream = Stream::Multi.new(alice)
    end

    it 'returns true if user is getting started' do
      alice.getting_started = true
      @stream.send(:welcome?).should be_true
    end

    it 'returns false if user is getting started' do
      alice.getting_started = false
      @stream.send(:welcome?).should be_false
    end
  end
end
