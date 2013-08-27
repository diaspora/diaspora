require 'spec_helper'

describe SearchController do
  before do
    @user = alice
    @aspect = @user.aspects.first
    sign_in :user, @user
  end

  describe 'query is a person' do
    @lola = FactoryGirl.create(:person, :diaspora_handle => "lola@example.org",
                                         :profile => FactoryGirl.build(:profile, :first_name => "Lola",
                                                                   :last_name => "w", :searchable => false))
    it 'goes to people index page' do
      get :search, :q => 'eugene'
      response.should be_redirect
    end
  end


  describe 'query is a tag' do
    it 'goes to a tag page' do
      get :search, :q => '#cats'
      response.should redirect_to(tag_path('cats'))
    end
    
    it 'removes dots from the query' do
      get :search, :q => '#cat.s'
      response.should redirect_to(tag_path('cats'))
    end

    it 'stay on the page if you search for the empty hash' do
      get :search, :q => '#'
      flash[:error].should be_present
    end
  end


end
