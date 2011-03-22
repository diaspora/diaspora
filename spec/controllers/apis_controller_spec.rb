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

  describe '#posts' do

    it 'returns all of the public posts' do
      get :posts_index, :format => :json
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
      get :posts_index, :format => :json, :per_page=> 1
      JSON.parse(response.body).count.should == 1
    end
  end

  describe '#post' do
    it 'returns a post' do
      get :posts, :guid => @status_message1.guid, :format => :json
      p = JSON.parse(response.body)
      p['guid'].should == @status_message1.guid
    end

    it 'returns a 404 if does not exsist' do
      get :posts, :guid => 999
      response.code.should == '404'
    end
  end

  describe '#tag_posts' do
    it 'succeeds' do
      get :tag_posts, :tag => 'flay'
      p = JSON.parse(response.body).first
      p['guid'].should == @status_message1.guid
    end
  end

  describe '#tag_people' do
    it 'succeeds' do
      get :tag_people, :tag => 'zord'
      p = JSON.parse(response.body).first
      p['person']['id'].should == @person.id
    end
  end
  
  describe '#people_index' do
    it 'succeeds' do
      get :people_index, :q => 'bobby'
      p = JSON.parse(response.body)
      p.count.should_be 1
      p.first['person']['id'].should == @person.id

    end
  end

  describe '#people' do
  end
end
