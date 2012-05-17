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
      @url = activity_streams_photos_path
    end
    it 'allows oauth authentication' do
      token = Factory(:oauth_access_token)
      post @url, @json.merge!(:oauth_token => token.access_token)
      response.should be_success
    end

    it 'denies an invalid oauth token' do
      post @url, @json.merge!(:oauth_token => "aoijgosidjg")
      response.status.should == 401
      response.body.should be_empty
    end

    it 'allows token authentication' do
      bob.reset_authentication_token!
      post @url, @json.merge!(:auth_token => bob.authentication_token)
      response.should be_success
    end

    it 'correctly denies an invalid token' do
      post @url, @json.merge!(:auth_token => "iudsfghpsdifugh")
      response.status.should == 401
    end
  end
end
