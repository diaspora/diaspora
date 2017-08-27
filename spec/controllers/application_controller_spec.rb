# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ApplicationController, :type => :controller do
  controller do
    def index
      head :ok
    end
  end

  before do
    sign_in alice
  end

  describe '#set_diaspora_headers' do
    it 'sets the version header' do
      get :index
      expect(response.headers['X-Diaspora-Version']).to include AppConfig.version.number.get
    end

    context 'with git info' do
      before do
        allow(AppConfig).to receive(:git_available?).and_return(true)
        allow(AppConfig).to receive(:git_update).and_return('yesterday')
        allow(AppConfig).to receive(:git_revision).and_return('02395')
      end

      it 'sets the git header' do
        get :index
        expect(response.headers['X-Git-Update']).to eq('yesterday')
        expect(response.headers['X-Git-Revision']).to eq('02395')
      end
    end
  end

  describe '#mobile_switch' do
    it 'sets the format to :mobile' do
      request.format = :html
      session[:mobile_view] = true
      get :index
      expect(request.format.mobile?).to be true
    end

    it 'uses :html for :tablets' do
      request.format = :tablet
      session[:tablet_view] = true
      get :index
      expect(request.format.html?).to be true
    end

    it "doesn't mess up other formats, like json" do
      get :index, :format => 'json'
      expect(request.format.json?).to be true
    end

    it "doesn't mess up other formats, like xml, even with :mobile session" do
      session[:mobile_view] = true
      get :index, :format => 'xml'
      expect(request.format.xml?).to be true
    end
  end

  describe '#tags' do
    before do
      @tag = ActsAsTaggableOn::Tag.create!(:name => "partytimeexcellent")
      TagFollowing.create!(:tag => @tag, :user => alice)
    end

    it 'queries current_users tag if there are tag_followings' do
      expect(@controller.send(:tags)).to eq([@tag])
    end

    it 'does not query twice' do
      expect_any_instance_of(User).to receive(:followed_tags).once.and_return([@tag])
      @controller.send(:tags)
      @controller.send(:tags)
    end
  end

  describe "#after_sign_in_path_for" do
    context 'getting started true on user' do
      before do
        alice.update_attribute(:getting_started, true)
      end

      it "redirects to getting started if the user has getting started set to true and a blank profile" do
        expect(@controller.send(:after_sign_in_path_for, alice)).to eq(getting_started_path)
      end
    end

    context "getting started true and one tag present on user" do
      before do
        alice.update_attribute(:getting_started, true)
        @tag = ActsAsTaggableOn::Tag.create!(name: "partytimeexcellent")
        allow(@controller).to receive(:current_user).and_return(alice)
        TagFollowing.create!(tag: @tag, user: alice)
      end

      it "redirects to stream if the user has getting started set to true and has already added tags" do
        expect(@controller.send(:after_sign_in_path_for, alice)).to eq(stream_path)
      end
    end

    context "getting started true and user image present on user" do
      before do
        alice.update_attribute(:getting_started, true)
        # Just set the image url...
        alice.profile.image_url = "something not nil"
        allow(@controller).to receive(:current_user).and_return(alice)
      end

      it "redirects to stream if the user has getting started set to true and has already added a photo" do
        expect(@controller.send(:after_sign_in_path_for, alice)).to eq(stream_path)
      end
    end
  end

  describe "#after_sign_out_path_for" do
    it "can handle a nil HTTP_USER_AGENT" do
      @request.headers["HTTP_USER_AGENT"] = nil
      expect(@controller.send(:after_sign_out_path_for, alice)).to eq(new_user_session_path)
    end
  end

  describe "#set_grammatical_gender" do
    it "is called on page load" do
      expect(@controller).to receive(:set_grammatical_gender)
      get :index
    end

    context "for inflected locales" do
      before do
        alice.language = :pl
        alice.save
      end

      it "returns nil for an empty gender" do
        alice.person.profile.gender = ""
        alice.person.profile.save
        get :index
        expect(assigns[:grammatical_gender]).to be_nil
      end

      it "returns nil for an unrecognized gender" do
        alice.person.profile.gender = "robot"
        alice.person.profile.save
        get :index
        expect(assigns[:grammatical_gender]).to be_nil
      end

      it "sets the correct grammatical gender" do
        alice.person.profile.gender = "ona"
        alice.person.profile.save
        get :index
        expect(assigns[:grammatical_gender]).to eq(:f)
      end
    end
  end
end
