require 'spec_helper'

describe ActivityStreams::PhotosController do
  describe '#show' do
    before do
      @photo = Factory(:activity_streams_photo, :author => bob.person)
      sign_in :user, alice
    end
    it 'succeeds' do
      get :show, :id => @photo.id
      response.should be_success
    end
  end
end

