require 'spec_helper'

class ApisController
  include ActionController::UrlFor
  include ActionController::Testing
  include Rails.application.routes.url_helpers
  include ActionController::Compatibility
end

describe ApisController do
   before :all do
    @status_message1 = Factory(:status_message, :text => '#bobby #flay #sux', :public => true)

    @status_message2 = Factory(:status_message, :public => true)
    @status_message3 = Factory(:status_message) 
    @person = Factory(:person, :profile => Factory.build(:profile,:first_name => 'bobby', :searchable => true, :tag_string => '#zord'))
    @person.profile.save
   end

  describe '#public_timeline' do

    it 'returns all of the public posts' do
      get :public_timeline, :format => :json
      @posts = JSON.parse(response.body)
      @posts.count.should == 2
    end

    it 'accepts an order paramater' do
      pending
    end

    it 'accpets a page paramater' do
      pending
    end

    it 'accepts a per_page param' do
      get :public_timeline, :format => :json, :per_page=> 1
      JSON.parse(response.body).count.should == 1
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
      p['user'].should == @status_message1.author.to_json(:format => :twitter)
      p['created_at'].should_not be_nil
    end

    it 'returns a 404 if does not exsist' do
      get :statuses, :guid => 999
      response.code.should == '404'
    end
  end

  describe '#users' do
    it 'succeeds' do
      get :users, :user_id => @person.id, :format => :json
      p = JSON.parse(response.body)
      p['id'].should == @person.id
      p['name'].should == @person.name
      p['screen_name'].should == @person.diaspora_handle
      p['profile_image_url'].should == @person.profile.image_url(:thumb_small)
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
      pending
      get :tag_posts, :tag => 'flay'
      p = JSON.parse(response.body).first
      p['id'].should == @status_message1.guid
    end
  end

  describe '#tag_people' do
    it 'succeeds' do
      pending
      get :tag_people, :tag => 'zord'
      p = JSON.parse(response.body).first
      p['person']['id'].should == @person.id
    end
  end
  
end
