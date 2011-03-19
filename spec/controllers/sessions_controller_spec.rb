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

  let(:omniauth_auth) {
    { 'provider' => 'twitter',
      'uid'      => '2',
      'user_info'   => { 'nickname' => 'grimmin' },
      'credentials' => { 'token' => 'tokin', 'secret' =>"not_so_much" }
      }
  }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    @user   = alice
    @service = Services::Facebook.new(:access_token => "yeah")
    @user.services << @service
    @user.save
  end

  describe "#create" do
    it 'queues up an update job' do
      Resque.should_receive(:enqueue).with(Job::UpdateServiceUsers, @service.id)
      post :create, {"user"=>{"remember_me"=>"0", "username"=>"alice",
                               "password"=>"evankorth"}}
    end
  end
end
