require 'helper'

describe Twitter::Client do
  Twitter::Configuration::VALID_FORMATS.each do |format|
    context ".new(:format => '#{format}')" do
      before do
        @client = Twitter::Client.new(:format => format, :consumer_key => 'CK', :consumer_secret => 'CS', :oauth_token => 'OT', :oauth_token_secret => 'OS')
      end

      describe ".follow" do

        context "with :follow => true passed" do

          before do
            stub_post("friendships/create.#{format}").
              with(:body => {:screen_name => "sferik", :follow => "true"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.follow("sferik", :follow => true)
            a_post("friendships/create.#{format}").
              with(:body => {:screen_name => "sferik", :follow => "true"}).
              should have_been_made
          end

          it "should return the befriended user" do
            user = @client.follow("sferik", :follow => true)
            user.name.should == "Erik Michaels-Ober"
          end

        end

        context "with :follow => false passed" do

          before do
            stub_post("friendships/create.#{format}").
              with(:body => {:screen_name => "sferik"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.follow("sferik", :follow => false)
            a_post("friendships/create.#{format}").
              with(:body => {:screen_name => "sferik"}).
              should have_been_made
          end

          it "should return the befriended user" do
            user = @client.follow("sferik", :follow => false)
            user.name.should == "Erik Michaels-Ober"
          end

        end

        context "without :follow passed" do

          before do
            stub_post("friendships/create.#{format}").
              with(:body => {:screen_name => "sferik"}).
              to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          end

          it "should get the correct resource" do
            @client.follow("sferik")
            a_post("friendships/create.#{format}").
              with(:body => {:screen_name => "sferik"}).
              should have_been_made
          end

          it "should return the befriended user" do
            user = @client.follow("sferik")
            user.name.should == "Erik Michaels-Ober"
          end

        end

      end

      describe ".unfollow" do

        before do
          stub_delete("friendships/destroy.#{format}").
            with(:query => {:screen_name => "sferik"}).
            to_return(:body => fixture("sferik.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.unfollow("sferik")
          a_delete("friendships/destroy.#{format}").
            with(:query => {:screen_name => "sferik"}).
            should have_been_made
        end

        it "should return the unfollowed" do
          user = @client.friendship_destroy("sferik")
          user.name.should == "Erik Michaels-Ober"
        end

      end

      describe ".friendship_exists?" do

        before do
          stub_get("friendships/exists.#{format}").
            with(:query => {:user_a => "sferik", :user_b => "pengwynn"}).
            to_return(:body => fixture("true.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
          stub_get("friendships/exists.#{format}").
            with(:query => {:user_a => "pengwynn", :user_b => "sferik"}).
            to_return(:body => fixture("false.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.friendship_exists?("sferik", "pengwynn")
          a_get("friendships/exists.#{format}").
            with(:query => {:user_a => "sferik", :user_b => "pengwynn"}).
            should have_been_made
        end

        it "should return true if user_a follows user_b" do
          friendship_exists = @client.friendship_exists?("sferik", "pengwynn")
          friendship_exists.should be_true
        end

        it "should return false if user_a does not follows user_b" do
          friendship_exists = @client.friendship_exists?("pengwynn", "sferik")
          friendship_exists.should be_false
        end

      end

      describe ".friendship" do

        before do
          stub_get("friendships/show.#{format}").
            with(:query => {:source_screen_name => "sferik", :target_screen_name => "pengwynn"}).
            to_return(:body => fixture("relationship.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.friendship(:source_screen_name => "sferik", :target_screen_name => "pengwynn")
          a_get("friendships/show.#{format}").
            with(:query => {:source_screen_name => "sferik", :target_screen_name => "pengwynn"}).
            should have_been_made
        end

        it "should return detailed information about the relationship between two users" do
          relationship = @client.friendship(:source_screen_name => "sferik", :target_screen_name => "pengwynn")
          relationship.source.screen_name.should == "sferik"
        end

      end

      describe ".friendships_incoming" do

        before do
          stub_get("friendships/incoming.#{format}").
            with(:query => {:cursor => "-1"}).
            to_return(:body => fixture("id_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.friendships_incoming
          a_get("friendships/incoming.#{format}").
            with(:query => {:cursor => "-1"}).
            should have_been_made
        end

        it "should return an array of numeric IDs for every user who has a pending request to follow the authenticating user" do
          id_list = @client.friendships_incoming
          id_list.ids.should be_an Array
          id_list.ids.first.should == 146197851
        end

      end

      describe ".friendships_outgoing" do

        before do
          stub_get("friendships/outgoing.#{format}").
            with(:query => {:cursor => "-1"}).
            to_return(:body => fixture("id_list.#{format}"), :headers => {:content_type => "application/#{format}; charset=utf-8"})
        end

        it "should get the correct resource" do
          @client.friendships_outgoing
          a_get("friendships/outgoing.#{format}").
            with(:query => {:cursor => "-1"}).
            should have_been_made
        end

        it "should return an array of numeric IDs for every protected user for whom the authenticating user has a pending follow request" do
          id_list = @client.friendships_outgoing
          id_list.ids.should be_an Array
          id_list.ids.first.should == 146197851
        end
      end
    end
  end
end
