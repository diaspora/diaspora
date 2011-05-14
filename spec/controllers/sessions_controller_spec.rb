#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

class Object
  def id
    super
  end
end

describe SessionsController do
  include Devise::TestHelpers

  let(:mock_access_token) { Object.new }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = alice
    @user.password = "evankorth"
    @user.password_confirmation = "evankorth"
    @user.save
  end

  describe "#create" do
    it "redirects to / for a normal user" do
      post :create, {"user" => {"remember_me" => "0", "username" => @user.username, "password" => "evankorth"}}
      response.should redirect_to root_path
    end
    it "redirects to / for a mobile user" do
      @request.env['HTTP_USER_AGENT'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7'
      post :create, {"user" => {"remember_me" => "0", "username" => @user.username, "password" => "evankorth"}}
      response.should redirect_to root_path
    end
    it 'queues up an update job' do
      service = Services::Facebook.new(:access_token => "yeah")
      @user.services << service
      @user.save
      
      Resque.should_receive(:enqueue).with(Job::UpdateServiceUsers, service.id)
      post :create, {"user"=>{"remember_me"=>"0", "username"=> @user.username,
                               "password"=>"evankorth"}}
    end
  end
end