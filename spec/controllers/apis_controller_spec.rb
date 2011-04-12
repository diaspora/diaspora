require 'spec_helper'

describe ApisController do
   before(:all) do
    @status_message1 = Factory(:status_message, :text => '#bobby #flay #sux', :public => true, :updated_at => Time.now + 20)

    @status_message2 = Factory(:status_message, :text => '#aobby', :public => true, :created_at => Time.now + 10)
    @status_message3 = Factory(:status_message, :created_at => Time.now + 15)
    @person = Factory(:person, :profile => Factory.build(:profile,:first_name => 'bobby', :searchable => true, :tag_string => '#zord'))
    @person.profile.save
   end

  describe '#public_timeline' do
    it 'returns all of the public posts' do
      get :public_timeline, :format => :json
      @posts = JSON.parse(response.body)
      @posts.map{|p| p['id']}.should == [@status_message2.guid, @status_message1.guid]
      @posts.count.should == 2
    end

    it 'accepts an order paramater' do
      get :public_timeline, :format => :json, :order => 'updated_at'
      @posts = JSON.parse(response.body)
      @posts.map{|p| p['id']}.should == [@status_message1.guid, @status_message2.guid]
    end

    it 'does not allow arbitrary orders' do
      get :public_timeline, :format => :json, :order => 'text'
      @posts = JSON.parse(response.body)
      @posts.map{|p| p['id']}.should == [@status_message2.guid, @status_message1.guid]
    end

    it 'accepts a page paramater' do
      get :public_timeline, :format => :json, :per_page=> 1, :page => 2
      JSON.parse(response.body).first['id'].should == @status_message1.guid
    end

    it 'accepts a per_page param' do
      get :public_timeline, :format => :json, :per_page=> 1
      JSON.parse(response.body).count.should == 1
    end
  end

  context 'protected timelines' do
    let(:authenticate){
      sign_in(:user, @user);
      @controller.stub(:current_user).and_return(@user)
    }

    before do
      @message1 = alice.post(:status_message, :text=> "hello", :to => alice.aspects.first)
      @message2 = eve.post(:status_message, :text=> "hello", :to => eve.aspects.first)
    end

    describe '#home_timeline' do
      it 'authenticates' do
        get :home_timeline, :format => :json
        response.code.should == '401'
      end

      it 'shows posts for alice' do
        @user = alice
        authenticate

        get :home_timeline, :format => :json
        p = JSON.parse(response.body)

        p.length.should == 1
        p[0]['id'].should == @message1.guid
      end

      it 'shows posts for eve' do
        @user = eve
        authenticate

        get :home_timeline, :format => :json
        p = JSON.parse(response.body)

        p.length.should == 1
        p[0]['id'].should == @message2.guid
      end

      it 'shows posts for bob' do
        @user = bob
        authenticate

        get :home_timeline, :format => :json
        p = JSON.parse(response.body)

        p.length.should == 2
      end
    end

    describe '#user_timeline' do
      context 'unauthenticated' do
        it 'shows public posts' do
          get :user_timeline, :format => :json, :user_id => @status_message1.author.guid
          posts = JSON.parse(response.body)
          posts.first['id'].should == @status_message1.guid
          posts.length.should == 1
        end
        it 'does not show non-public posts' do
          get :user_timeline, :format => :json, :user_id => alice.person.guid
          posts = JSON.parse(response.body)
          posts.should be_empty
        end
      end
      context 'authenticated' do
        context 'with bob logged in' do
          before do
            @user = bob
            authenticate
          end

          it 'shows alice' do
            get :user_timeline, :format => :json, :user_id => alice.person.guid
            p = JSON.parse(response.body)

            p.length.should == 1
            p[0]['id'].should == @message1.guid
          end

          it 'shows eve' do
            get :user_timeline, :format => :json, :user_id => eve.person.guid
            p = JSON.parse(response.body)

            p.length.should == 1
            p[0]['id'].should == @message2.guid
          end

          it 'shows bob' do
            get :user_timeline, :format => :json, :user_id => bob.person.guid
            p = JSON.parse(response.body)
            p.length.should == 0
          end
        end

        context 'with alice logged in' do
          before do
            @user = alice
            authenticate
          end

          it 'shows alice' do
            get :user_timeline, :format => :json, :user_id => alice.person.guid
            p = JSON.parse(response.body)

            p.length.should == 1
            p[0]['id'].should == @message1.guid
          end

          it 'shows eve' do
            get :user_timeline, :format => :json, :user_id => eve.person.guid
            p = JSON.parse(response.body)
            p.length.should == 0
          end
        end
      end
    end
  end

  describe '#users_profile_image' do
    it 'redirects on success' do
      get :users_profile_image, :screen_name => bob.diaspora_handle, :format => :json
      response.should redirect_to(bob.person.profile.image_url)
    end
  end

  describe '#statuses' do
    it 'returns a post' do
      get :statuses, :guid => @status_message1.guid, :format => :json
      p = JSON.parse(response.body)
      p['id'].should == @status_message1.guid
      p['text'].should == @status_message1.formatted_message(:plain_text => true)
      p['entities'].class.should == Hash
      p['source'].should == 'diaspora'
      p['user'].should == JSON.parse(@status_message1.author.to_json(:format => :twitter))
      p['created_at'].should_not be_nil
    end

    it 'returns a 404 if does not exsist' do
      get :statuses, :guid => '999'
      response.code.should == '404'
    end
  end

  describe '#users' do
    it 'succeeds' do
      get :users, :user_id => alice.person.guid, :format => :json
      p = JSON.parse(response.body)
      p['id'].should == alice.person.guid
      p['name'].should == alice.person.name
      p['screen_name'].should == alice.person.diaspora_handle
      p['profile_image_url'].should == alice.person.profile.image_url(:thumb_small)
      p['created_at'].should_not be_nil
    end
  end

  describe '#users_search' do
    it 'searches' do
      get :users_search, :q => @person.name, :format => :json
      p = JSON.parse(response.body)
      response.code.should == '200'
    end
  end

  describe '#tag_posts' do
    it 'succeeds' do
      get :tag_posts, :tag => 'flay'
      p = JSON.parse(response.body).first
      p['id'].should == @status_message1.guid
      p['user']['id'].should == @status_message1.author.guid
    end
  end

  describe '#tag_people' do
    it 'succeeds' do
      get :tag_people, :tag => 'zord'
      p = JSON.parse(response.body).first
      p['id'].should == @person.guid
    end
  end
end
