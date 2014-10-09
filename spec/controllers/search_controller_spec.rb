require 'spec_helper'

describe SearchController, :type => :controller do
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
      expect(response).to be_redirect
    end
  end


  describe 'query is a tag' do
    it 'goes to a tag page' do
      get :search, :q => '#cats'
      expect(response).to redirect_to(tag_path('cats'))
    end
    
    it 'removes dots from the query' do
      get :search, :q => '#cat.s'
      expect(response).to redirect_to(tag_path('cats'))
    end

    it 'stay on the page if you search for the empty hash' do
      get :search, :q => '#'
      expect(flash[:error]).to be_present
    end
  end

  describe '#search_query' do
    it 'strips the term parameter' do
      @controller.params[:term] = ' IN SPACE! '
      expect(@controller.send(:search_query)).to eq 'IN SPACE!'
    end

    it 'strips the q parameter' do
      @controller.params[:q] = ' IN SPACE! '
      expect(@controller.send(:search_query)).to eq 'IN SPACE!'
    end
  end

end
