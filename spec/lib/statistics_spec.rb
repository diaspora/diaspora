require 'spec_helper'
require 'lib/statistics'

describe Statistics do

  before do
    @stats = Statistics.new(time, time - 1.week)
    @result = [{"id" => alice.id , "count" => 0 },
                 {"id" => bob.id , "count" => 1 },
                 {"id" => eve.id , "count" => 0 },
                 {"id" => local_luke.id , "count" => 0 },
                 {"id" => local_leia.id , "count" => 0 },
      ]
  end

  describe '#posts_count_sql' do
    it "pulls back an array of post counts and ids" do
      Factory.create(:status_message, :author => bob.person)
      User.connection.select_all(@stats.posts_count_sql).should =~ @result
    end
  end

  describe '#invites_sent_count_sql' do
    it "pulls back an array of invite counts and ids" do
      Invitation.batch_invite(["a@a.com"], :sender => bob, :aspect => bob.aspects.first, :service => 'email')
      User.connection.select_all(@stats.invites_sent_count_sql).should =~ @result
    end
  end

  describe '#tags_followed_count_sql' do
    it "pulls back an array of tag following counts and ids" do
      TagFollowing.create!(:user => bob, :tag_id => 1)
      User.connection.select_all(@stats.tags_followed_count_sql).should =~ @result
    end
  end

  describe '#mentions_count_sql' do
    it "pulls back an array of mentions following counts and ids" do
      post = Factory.create(:status_message, :author => bob.person)
      Mention.create(:post => post, :person => bob.person)
      User.connection.select_all(@stats.mentions_count_sql).should =~ @result
    end
  end

  describe '#sign_in_count_sql' do
    it "pulls back an array of sign_in_counts and ids" do
      bob.sign_in_count = 1
      bob.save!
      User.connection.select_all(@stats.sign_in_count_sql).should =~ @result
    end
  end

  describe "#correlation" do
    it 'returns the correlation coefficient' do
      @stats.correlation([1,2],[1,2]).to_s.should == 1.0.to_s
      @stats.correlation([1,2,1,2],[1,1,2,2]).to_s.should == 0.0.to_s
    end
  end
  describe "#correlation_hash" do

    it 'it returns a hash of including start and end time' do
      time = Time.now

      hash = @stats.correlation_hash
      hash[:starrt_time].should == time
      hash[:end_time].should == time - 1.week
    end

    it 'returns the post count (and sign_in_count) correlation' do
      @stats.stub(:posts_count_correlation).and_return(0.5)

      @stats.generate_correlations[:posts_count].should == 0.5
    end
  end

  context 'todos' do
    before do
      pending
    end

    # requires a threshold

    describe '#disabled_email_count_sql' do
    end

    # binary things
    describe '#completed_getting_started_count_sql' do
    end

    describe 'used_cubbies_sql' do
    end

    describe '.sign_up_method_sql' do
    end
  end
end
