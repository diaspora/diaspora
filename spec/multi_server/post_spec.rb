require 'spec_helper'

unless Server.all.empty?
  describe "commenting" do
    before(:all) do
      Server.start
    end

    after(:all) do
      Server.stop
    end
    before do
      Server.truncate_databases
      @post = nil
      Server[0].in_scope do
        Factory(:user_with_aspect, :username => "poster")
      end

      Server[1].in_scope do
        recipient = Factory(:user_with_aspect, :username => "recipient")
        recipients_aspect = recipient.aspects.where(:name => "generic").first
        person = Webfinger.new("poster@localhost:#{Server[0].port}").fetch
        person.save!
        recipient.share_with(person, recipients_aspect)
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
        posters_aspect = poster.aspects.where(:name => "generic").first
        person = Person.find_by_diaspora_handle("recipient@localhost:#{Server[1].port}")
        poster.share_with(person, posters_aspect)
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
