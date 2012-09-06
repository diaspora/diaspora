require 'spec_helper'
require Rails.root.join('lib', 'statistics')

describe Statistics do

  def result_should_equal( actual )
    actual.count.should == @result.count
    @result.each do |expected_hash|
      actual.find { |actual_hash|
        actual_hash['id'].to_i == expected_hash['id'].to_i &&
        actual_hash['count'].to_i == expected_hash['count'].to_i
      }.should_not be_nil
    end
  end

  before do
    @time = Time.now
    @stats = Statistics.new#(@time, @time - 1.week)
    @result = [{"id" => alice.id , "count" => 0 },
                 {"id" => bob.id , "count" => 1 },
                 {"id" => eve.id , "count" => 0 },
                 {"id" => local_luke.id , "count" => 0 },
                 {"id" => local_leia.id , "count" => 0 }]
  end

  describe '#posts_count_sql' do
    it "pulls back an array of post counts and ids" do
      FactoryGirl.create(:status_message, :author => bob.person)
      result_should_equal User.connection.select_all(@stats.posts_count_sql)
    end
  end

  describe '#comments_count_sql' do
    it "pulls back an array of post counts and ids" do
      status_message = FactoryGirl.create(:status_message, :author => alice.person)
      bob.comment!(status_message, "sup")
      result_should_equal User.connection.select_all(@stats.comments_count_sql)
    end
  end


  describe '#invites_sent_count_sql' do
    it "pulls back an array of invite counts and ids" do
      Invitation.batch_invite(["a@a.com"], :sender => bob, :aspect => bob.aspects.first, :service => 'email')
      result_should_equal User.connection.select_all(@stats.invites_sent_count_sql)
    end
  end

  describe '#tags_followed_count_sql' do
    it "pulls back an array of tag following counts and ids" do
      TagFollowing.create!(:user => bob, :tag_id => 1)
      result_should_equal User.connection.select_all(@stats.tags_followed_count_sql)
    end
  end

  describe '#mentions_count_sql' do
    it "pulls back an array of mentions following counts and ids" do
      post = FactoryGirl.create(:status_message, :author => bob.person)
      Mention.create(:post => post, :person => bob.person)
      result_should_equal User.connection.select_all(@stats.mentions_count_sql)
    end
  end

  describe '#contacts_sharing_with_count_sql' do
    it "pulls back an array of mentions following counts and ids" do
      # bob is sharing with alice and eve in the spec setup
      alice.share_with(eve.person, alice.aspects.first)
      @result = [{"id" => alice.id , "count" => 2 },
                 {"id" => bob.id , "count" => 2 },
                 {"id" => eve.id , "count" => 1 },
                 {"id" => local_luke.id , "count" => 2 },
                 {"id" => local_leia.id , "count" => 2 }]

      result_should_equal User.connection.select_all(@stats.contacts_sharing_with_count_sql)
    end
  end

  describe '#sign_in_count_sql' do
    it "pulls back an array of sign_in_counts and ids" do
      bob.sign_in_count = 1
      bob.save!
      result_should_equal User.connection.select_all(@stats.sign_in_count_sql)
    end
  end

  describe "#fb_connected_distribution_sql" do
    it "pulls back an array of sign_in_counts, connected, uids" do
      bob.sign_in_count = 1
      bob.services << FactoryGirl.create(:service, :type => "Services::Facebook", :user => bob)
      bob.save!

      eve.services << FactoryGirl.create(:service, :type => "Services::Facebook", :user => eve)
      eve.save!


      @result = [{"id" => alice.id , "count" => 0, "connected" => 0 },
                 {"id" => bob.id , "count" => 1, "connected" => 1 },
                 {"id" => eve.id , "count" => 0, "connected" => 1 },
                 {"id" => local_luke.id , "count" => 0, "connected" => 0 },
                 {"id" => local_leia.id , "count" => 0, "connected" => 0 }]

      @stats.fb_connected_distribution.should =~ @result
    end
  end

  ["posts_count", "comments_count", "invites_sent_count", "tags_followed_count",
    "mentions_count", "sign_in_count", "contacts_sharing_with_count" ].each do |method|

    it "#{method}_sql calls where_sql" do
      @stats.should_receive(:where_clause_sql)

      @stats.send("#{method}_sql".to_sym)
    end

    if !["sign_in_count", "tags_followed_count"].include?(method)
      it "#generate_correlations calls correlate with #{method} and sign_in_count" do
        @stats.stub(:correlate).and_return(0.5)
        @stats.should_receive(:correlate).with(method.to_sym,:sign_in_count).and_return(0.75)
        @stats.generate_correlations
      end
    end
  end


  describe "#correlation" do
    it 'returns the correlation coefficient' do
      @stats.correlation([1,2],[1,2]).to_s.should == 1.0.to_s
      @stats.correlation([1,2,1,2],[1,1,2,2]).to_s.should == 0.0.to_s
    end
  end
  describe "#generate_correlations" do
    it 'returns the post count (and sign_in_count) correlation' do
      bob.sign_in_count = 1
      bob.post(:status_message, :text => "here is a message")
      bob.save!

      c = @stats.generate_correlations[:posts_count].round(1).should == 1.0
    end
  end

  describe "#correlate" do
    it 'calls correlation with post' do
      User.connection.should_receive(:select_all).and_return([{"id"=> 1, "count" => 7},
                                                            {"id" => 2, "count" => 8},
                                                            {"id" => 3, "count" => 9}],
                                                            [{"id"=> 1, "count" => 17},
                                                            {"id" => 3, "count" => 19}]
                                                            )

      @stats.should_receive(:correlation).with([7,9],[17,19]).and_return(0.5)
      @stats.correlate(:posts_count,:sign_in_count).should == 0.5
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
