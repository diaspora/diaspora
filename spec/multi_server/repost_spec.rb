
require 'spec_helper'


unless Server.all.empty?
  describe "reposting" do
    before(:all) do
      WebMock::Config.instance.allow_localhost = true
      #Server.all.each{|s| s.kill if s.running?}
      #Server.all.each{|s| s.run}
    end

    after(:all) do
      #Server.all.each{|s| s.kill if s.running?}
      #sleep(1)
      #Server.all.each{|s| puts "Server at port #{s.port} still running." if s.running?}
      WebMock::Config.instance.allow_localhost = false
    end

    it 'fetches the original post from the root server' do
      Server.all[0].in_scope do
        original_poster = Factory.create(:user_with_aspect, :username => "original_poster")
        resharer = Factory.create(:user_with_aspect, :username => "resharer")

        connect_users_with_aspects(original_poster, resharer)

        original_post = original_poster.post(:status_message, 
                                               :public => true,
                                               :text => "Awesome Sauce!",
                                               :to => 'all')
        resharer.post(:reshare, :root_id => original_post.id, :to => 'all')
      end

      Server.all[1].in_scope do
        recipient = Factory.create(:user_with_aspect, :username => "resharer")
      end

      Server.all[0].in_scope do
        r = User.find_by_username("resharer")
        person = Webfinger.new("recipient@localhost:#{Server.all[1].port}").fetch
        r.share_with(person, r.aspects.first)
      end
      Server.all[1].in_scope do
        r = User.find_by_username("recipient")
        person = Webfinger.new("resharer@localhost:#{Server.all[0].port}").fetch
        r.share_with(person, r.aspects.first)
      end
      

    end
  end
end
