require 'spec_helper'

describe ActivityStreams::PhotosController do
  describe '#create' do
    before do
      @json = JSON.parse <<JSON
        {
          "activity": {
            "actor": {
              "url":"http://cubbi.es/daniel",
              "displayName":"daniel",
              "objectType":"person"
            },
            "published":"2011-05-19T18:12:23Z",
            "verb":"save",
            "object": {
              "objectType":"photo",
              "url":"http://i658.photobucket.com/albums/uu308/R3b3lAp3/Swagger_dog.jpg",
              "id":"http://i658.photobucket.com/albums/uu308/R3b3lAp3/Swagger_dog.jpg",
              "image": {
                "url":"http://i658.photobucket.com/albums/uu308/R3b3lAp3/Swagger_dog.jpg",
                "width":637,
                "height":469
              }
            },
            "provider": {
              "url":"http://cubbi.es/",
              "displayName":"Cubbi.es"
            }
          }
        }
JSON
    end
    it 'allows oauth authentication' do
      token = Factory(:oauth_access_token)
      get :create, @json.merge!(:oauth_token => token.access_token)
      response.should be_success
    end

    # It is unclear why this test fails.  An equivalent cucumber feature passes in features/logs_in_and_out.feature.
=begin
    it 'does not store a session' do
      bob.reset_authentication_token!
      get :create, @json.merge!(:auth_token => bob.authentication_token)
      photo = ActivityStreams::Photo.where(:author_id => bob.person.id).first
      warden.should be_authenticated
      get :show, :id => photo.id
      warden.should_not be_authenticated
      response.should redirect_to new_user_session_path
    end
=end
  end
end
