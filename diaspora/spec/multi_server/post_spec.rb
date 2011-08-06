require 'spec_helper'

unless Server.all.empty?
  describe "commenting" do
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
      @post = nil
      Server[0].in_scope do
        Factory.create(:user_with_aspect, :username => "poster")
      end

      Server[1].in_scope do
        recipient = Factory.create(:user_with_aspect, :username => "recipient")
        person = Webfinger.new("poster@localhost:#{Server[0].port}").fetch
        person.save!
        recipient.share_with(person, recipient.aspects.first)
      end
    end

    it 'sends public posts to remote followers' do
      Server[0].in_scope do
        @post = User.find_by_username("poster").
          post(:status_message,
              :public => true,
              :text => "Awesome Sauce!",
              :to => 'all')
      end

      Server[1].in_scope do
        Post.exists?(:guid => @post.guid).should be_true
      end
    end

    it 'sends public posts to remote friends' do
      Server[0].in_scope do
        poster = User.find_by_username("poster")
        person = Person.find_by_diaspora_handle("recipient@localhost:#{Server[1].port}")
        poster.share_with(person, poster.aspects.first)
        @post = poster.
          post(:status_message,
              :public => true,
              :text => "Awesome Sauce!",
              :to => 'all')
      end

      Server[1].in_scope do
        Post.exists?(:guid => @post.guid).should be_true
      end
    end
  end
end
