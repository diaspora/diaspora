#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe DevUtilitiesController do
  render_views

  before do
    @tom = Factory.create(:user, :email => "tom@tom.joindiaspora.org")
    sign_in :user, @tom
  end

  describe "#zombiefriends" do
    it "succeeds" do
      get :zombiefriends
      response.should be_success
    end
  end

  describe "#set_profile_photo" do
    # In case anyone wants their config/backer_number.yml to still exist after running specs
    before do
      @backer_number_file = File.join(File.dirname(__FILE__), "..", "..", "config", "backer_number.yml")
      @temp_file = File.join(File.dirname(__FILE__), "..", "..", "config", "backer_number.yml-tmp")
      FileUtils.mv(@backer_number_file, @temp_file, :force => true)
    end
    after do
      if File.exists?(@temp_file)
        FileUtils.mv(@temp_file, @backer_number_file, :force => true)
      else
        FileUtils.rm_rf(@backer_number_file)
      end
    end
    it "succeeds" do
      get :set_backer_number, 'number' => '3'
      get :set_profile_photo
      response.should be_success
    end
  end
end
