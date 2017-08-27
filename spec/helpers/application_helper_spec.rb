# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

describe ApplicationHelper, :type => :helper do
  before do
    @user = alice
    @person = FactoryGirl.create(:person)
  end

  describe "#all_services_connected?" do
    before do
      AppConfig.configured_services = [1, 2, 3]

      def current_user
        @current_user
      end
      @current_user = alice
    end

    after do
      AppConfig.configured_services = nil
    end

    it 'returns true if all networks are connected' do
      3.times { |t| @current_user.services << FactoryGirl.build(:service) }
      expect(all_services_connected?).to be true
    end

    it 'returns false if not all networks are connected' do
      @current_user.services.delete_all
      expect(all_services_connected?).to be false
    end
  end

  describe "#jquery_include_tag" do
    describe "with jquery cdn" do
      before do
        AppConfig.privacy.jquery_cdn = true
      end

      it 'inclues jquery.js from jquery cdn' do
        expect(helper.jquery_include_tag).to match(/jquery\.com/)
      end

      it 'falls back to asset pipeline on cdn failure' do
        expect(helper.jquery_include_tag).to match(/document\.write/)
      end
    end

    describe "without jquery cdn" do
      before do
        AppConfig.privacy.jquery_cdn = false
      end

      it 'includes jquery.js from asset pipeline' do
        expect(helper.jquery_include_tag).to match(/jquery3-[0-9a-f]{64}\.js/)
        expect(helper.jquery_include_tag).not_to match(/jquery\.com/)
      end
    end

    it 'inclues jquery_ujs.js' do
      expect(helper.jquery_include_tag).to match(/jquery_ujs-[0-9a-f]{64}\.js/)
    end

    it "disables ajax caching" do
      expect(helper.jquery_include_tag).to match(/jQuery\.ajaxSetup/)
    end
  end

  describe "#donations_enabled?" do
    it "returns false when nothing is set" do
      expect(helper.donations_enabled?).to be false
    end

    it "returns true when the paypal donations is enabled" do
      AppConfig.settings.paypal_donations.enable = true
      expect(helper.donations_enabled?).to be true
    end

    it "returns true when the liberapay username is set" do
      AppConfig.settings.liberapay_username = "foo"
      expect(helper.donations_enabled?).to be true
    end

    it "returns true when the bitcoin_address is set" do
      AppConfig.settings.bitcoin_address = "bar"
      expect(helper.donations_enabled?).to be true
    end

    it "returns true when all the donations are enabled" do
      AppConfig.settings.paypal_donations.enable = true
      AppConfig.settings.liberapay_username = "foo"
      AppConfig.settings.bitcoin_address = "bar"
      expect(helper.donations_enabled?).to be true
    end
  end

  describe "#changelog_url" do
    let(:changelog_url_setting) {
      double.tap {|double| allow(AppConfig).to receive(:settings).and_return(double(changelog_url: double)) }
    }

    it "defaults to master branch changleog" do
      expect(changelog_url_setting).to receive(:present?).and_return(false)
      expect(AppConfig).to receive(:git_revision).and_return(nil)
      expect(changelog_url).to eq("https://github.com/diaspora/diaspora/blob/master/Changelog.md")
    end

    it "displays the changelog for the current git revision if set" do
      expect(changelog_url_setting).to receive(:present?).and_return(false)
      expect(AppConfig).to receive(:git_revision).twice.and_return("123")
      expect(changelog_url).to eq("https://github.com/diaspora/diaspora/blob/123/Changelog.md")
    end

    it "displays the configured changelog url if set" do
      expect(changelog_url_setting).to receive(:present?).and_return(true)
      expect(changelog_url_setting).to receive(:get)
        .and_return("https://github.com/diaspora/diaspora/blob/develop/Changelog.md")
      expect(AppConfig).not_to receive(:git_revision)
      expect(changelog_url).to eq("https://github.com/diaspora/diaspora/blob/develop/Changelog.md")
    end
  end

  describe '#pod_name' do
    it 'defaults to Diaspora*' do
      expect(pod_name).to  match /DIASPORA/i
    end

    it 'displays the supplied pod_name if it is set' do
      AppConfig.settings.pod_name = "Catspora"
      expect(pod_name).to match "Catspora"
    end
  end

  describe '#pod_version' do
    it 'displays the supplied pod_version if it is set' do
      AppConfig.version.number = "0.0.1.0"
      expect(pod_version).to match "0.0.1.0"
    end
  end
end
