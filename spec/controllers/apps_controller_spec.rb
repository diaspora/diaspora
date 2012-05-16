
require 'spec_helper'

describe AppsController do
  describe '#show' do
    it 'works as long as you pass something as id' do
      FactoryGirl.create(:activity_streams_photo)
      get :show, :id => 'cubbies'
      response.should be_success
    end

  end
end
