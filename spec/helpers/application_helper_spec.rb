#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ApplicationHelper do
  before do
    @user = alice
    @person = FactoryGirl.create(:person)
  end

  describe "#contacts_link" do
    before do
      def current_user
        @current_user
      end
    end

    it 'links to community spotlight' do
      @current_user = FactoryGirl.create(:user)
      contacts_link.should == community_spotlight_path
    end

    it 'links to contacts#index' do
      @current_user = alice
      contacts_link.should == contacts_path
    end
  end

  describe "#all_services_connected?" do
    before do
      @old_configured_services = AppConfig.configured_services
      AppConfig.configured_services = [1, 2, 3]

      def current_user
        @current_user
      end
      @current_user = alice
    end

    after do
      AppConfig.configured_services = @old_configured_services
    end

    it 'returns true if all networks are connected' do
      3.times { |t| @current_user.services << FactoryGirl.build(:service) }
      all_services_connected?.should be_true
    end

    it 'returns false if not all networks are connected' do
      @current_user.services.delete_all
      all_services_connected?.should be_false
    end
  end

  describe "#jquery_include_tag" do
    describe "with jquery cdn" do
      before do
        AppConfig.privacy.jquery_cdn = true
      end

      it 'inclues jquery.js from jquery cdn' do
        jquery_include_tag.should match(/jquery\.com/)
      end

      it 'falls back to asset pipeline on cdn failure' do
        jquery_include_tag.should match(/document\.write/)
      end
    end

    describe "without jquery cdn" do
      before do
        AppConfig.privacy.jquery_cdn = false
      end

      it 'includes jquery.js from asset pipeline' do
        jquery_include_tag.should match(/jquery\.js/)
        jquery_include_tag.should_not match(/jquery\.com/)
      end
    end

    it 'inclues jquery_ujs.js' do
      jquery_include_tag.should match(/jquery_ujs\.js/)
    end

    it "disables ajax caching" do
      jquery_include_tag.should match(/jQuery\.ajaxSetup/)
    end
  end

  describe '#changelog_url' do
    it 'defaults to master branch changleog' do
      old_revision = AppConfig.git_revision
      AppConfig.git_revision = nil
      changelog_url.should == 'https://github.com/diaspora/diaspora/blob/master/Changelog.md'
      AppConfig.git_revision = old_revision
    end

    it 'displays the changelog for the current git revision if set' do
      old_revision = AppConfig.git_revision
      AppConfig.git_revision = '123'
      changelog_url.should == 'https://github.com/diaspora/diaspora/blob/123/Changelog.md'
      AppConfig.git_revision = old_revision
    end

  end

  describe '#pod_name' do
    it 'defaults to Diaspora*' do
      pod_name.should  match /DIASPORA/i
    end

    it 'displays the supplied pod_name if it is set' do
      old_name = AppConfig.settings.pod_name.get
      AppConfig.settings.pod_name = "Catspora"
      pod_name.should match "Catspora"
      AppConfig.settings.pod_name = old_name
    end
  end

  describe '#pod_version' do

    it 'displays the supplied pod_version if it is set' do
      old_version = AppConfig.version.number.get
      AppConfig.version.number = "0.0.1.0"
      pod_version.should match "0.0.1.0"
      AppConfig.version.number = old_version
    end
  end
end
