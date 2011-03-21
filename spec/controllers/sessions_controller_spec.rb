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
  
  render_views

  let(:mock_access_token) { Object.new }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user   = alice
    @user.password = "evankorth"
    @user.password_confirmation = "evankorth"
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
    @user.save
  end

  describe "#create" do
    it 'queues up an update job' do
      Resque.should_receive(:enqueue).with(Job::UpdateServiceUsers, @service.id)
      post :create, {"user"=>{"remember_me"=>"0", "username"=> @user.username,
                               "password"=>"evankorth"}}
    end
  end
end
