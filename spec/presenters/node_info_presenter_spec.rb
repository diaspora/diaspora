require "spec_helper"

describe NodeInfoPresenter do
  let(:presenter) { NodeInfoPresenter.new("1.0") }
  let(:hash) { presenter.as_json.as_json }

  describe "#as_json" do
    it "works" do
      expect(hash).to be_present
      expect(presenter.to_json).to be_a String
    end
  end

  describe "node info contents" do
    before do
      AppConfig.privacy.statistics.user_counts    = false
      AppConfig.privacy.statistics.post_counts    = false
      AppConfig.privacy.statistics.comment_counts = false
    end

    it "provides generic pod data in json" do
      expect(hash).to eq(
        "version"           => "1.0",
        "software"          => {
          "name"    => "diaspora",
          "version" => AppConfig.version_string
        },
        "protocols"         => {
          "inbound"  => ["diaspora"],
          "outbound" => ["diaspora"]
        },
        "services"          => ["facebook"],
        "openRegistrations" => AppConfig.settings.enable_registrations?,
        "usage"             => {
          "users" => {}
        },
        "metadata"          => {
          "nodeName" => AppConfig.settings.pod_name,
          "xmppChat" => AppConfig.chat.enabled?
        }
      )
    end

    context "when services are enabled" do
      before do
        AppConfig.services = {
          "facebook"  => {
            "enable"     => true,
            "authorized" => true
          },
          "twitter"   => {"enable" => true},
          "wordpress" => {"enable" => false},
          "tumblr"    => {
            "enable"     => true,
            "authorized" => false
          }
        }
      end

      it "provides services" do
        expect(hash).to include "services" => %w(twitter facebook)
      end
    end

    context "when some services are set to username authorized" do
      before do
        AppConfig.services = {
          "facebook"  => {
            "enable"     => true,
            "authorized" => "bob"
          },
          "twitter"   => {"enable" => true},
          "wordpress" => {
            "enable"     => true,
            "authorized" => "alice"
          },
          "tumblr"    => {
            "enable"     => true,
            "authorized" => false
          }
        }
      end

      it "it doesn't list those" do
        expect(hash).to include "services" => ["twitter"]
      end
    end

    context "when counts are enabled" do
      before do
        AppConfig.privacy.statistics.user_counts    = true
        AppConfig.privacy.statistics.post_counts    = true
        AppConfig.privacy.statistics.comment_counts = true
      end

      it "provides generic pod data and counts in json" do
        expect(hash).to include(
          "usage" => {
            "users"         => {
              "total"          => User.active.count,
              "activeHalfyear" => User.halfyear_actives.count,
              "activeMonth"    => User.monthly_actives.count
            },
            "localPosts"    => presenter.local_posts,
            "localComments" => presenter.local_comments
          }
        )
      end
    end

    context "when registrations are closed" do
      before do
        AppConfig.settings.enable_registrations = false
      end

      it "should mark open_registrations to be false" do
        expect(presenter.open_registrations?).to be false
      end
    end

    context "when chat is enabled" do
      before do
        AppConfig.chat.enabled = true
      end

      it "should mark the xmppChat metadata as true" do
        expect(hash).to include "metadata" => include("xmppChat" => true)
      end
    end
  end
end
