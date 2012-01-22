
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
        poster = Factory(:user_with_aspect, :username => "poster")
        @post = poster.post(:status_message,
                            :public => true,
                            :text => "Awesome Sauce!",
                            :to => 'all')
      end

      Server[1].in_scope do
        commenter = Factory(:user_with_aspect, :username => "commenter")
        person = Webfinger.new("poster@localhost:#{Server[0].port}").fetch
        person.save!
        Reshare.fetch_post(person, @post.guid).save!
      end
    end

    it 'allows an unknown commenter to comment on a public post' do
      pending
      Server[1].in_scope do
        commenter = User.find_by_username("commenter")
        commenter.comment("Hey", :post => Post.find_by_guid(@post.guid))
      end

      Server[0].in_scope do
        Person.exists?(:diaspora_handle => "commenter@localhost:#{Server[1].port}").should be_true
        @post.reload.comments.size.should == 0
      end
    end

  end
end
