
require 'spec_helper'


unless Server.all.empty?
  describe "reposting" do
    before(:all) do
      WebMock::Config.instance.allow_localhost = true
      enable_typhoeus
      #Server.all.each{|s| s.kill if s.running?}
      #Server.all.each{|s| s.run}
    end

    after(:all) do
      disable_typhoeus
      #Server.all.each{|s| s.kill if s.running?}
      #sleep(1)
      #Server.all.each{|s| puts "Server at port #{s.port} still running." if s.running?}
      WebMock::Config.instance.allow_localhost = false
    end
    before do
      Server.all.each{|s| s.truncate_database; }
      @original_post = nil
      Server[0].in_scope do
        original_poster = Factory.create(:user_with_aspect, :username => "original_poster")
        resharer = Factory.create(:user_with_aspect, :username => "resharer")

        connect_users_with_aspects(original_poster, resharer)

        @original_post = original_poster.post(:status_message,
                                               :public => true,
                                               :text => "Awesome Sauce!",
                                               :to => 'all')
      end

      Server[1].in_scope do
        recipient = Factory.create(:user_with_aspect, :username => "recipient")
      end

      Server[0].in_scope do
        r = User.find_by_username("resharer")
        person = Webfinger.new("recipient@localhost:#{Server[1].port}").fetch
        r.share_with(person, r.aspects.first)
      end
      Server[1].in_scope do
        r = User.find_by_username("recipient")
        person = Webfinger.new("resharer@localhost:#{Server[0].port}").fetch
        r.share_with(person, r.aspects.first)
      end

      Server[0].in_scope do
        r = User.find_by_username("resharer")
        r.post(:reshare, :root_guid => @original_post.guid, :to => 'all')
      end
    end

    it 'fetches the original post from the root server' do
      Server[1].in_scope do
        Post.exists?(:guid => @original_post.guid).should be_true
      end
    end

    it 'relays the retraction for the root post to recipients of the reshare' do
      Server[0].in_scope do
        poster = User.find_by_username 'original_poster'
        fantasy_resque do
          poster.retract @original_post
        end
      end

      Server[1].in_scope do
        Post.exists?(:guid => @original_post.guid).should be_false
      end
    end
  end
end
