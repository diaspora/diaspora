# frozen_string_literal: true

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
        "services"          => {
          "inbound"  => [],
          "outbound" => AppConfig.configured_services.map(&:to_s)
        },
        "openRegistrations" => AppConfig.settings.enable_registrations?,
        "usage"             => {
          "users" => {}
        },
        "metadata"          => {
          "nodeName" => AppConfig.settings.pod_name,
          "xmppChat" => AppConfig.chat.enabled?,
          "camo"     => {
            "markdown"   => AppConfig.privacy.camo.proxy_markdown_images?,
            "opengraph"  => AppConfig.privacy.camo.proxy_opengraph_thumbnails?,
            "remotePods" => AppConfig.privacy.camo.proxy_remote_pod_images?
          }
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
        expect(hash).to include "services" => include("outbound" => %w(twitter facebook))
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
        expect(hash).to include "services" => include("outbound" => ["twitter"])
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

    context "when camo is enabled" do
      before do
        AppConfig.privacy.camo.proxy_markdown_images = true
        AppConfig.privacy.camo.proxy_opengraph_thumbnails = true
        AppConfig.privacy.camo.proxy_remote_pod_images = true
      end

      it "should list enabled camo options in the metadata as true" do
        expect(hash).to include "metadata" => include("camo" => {
                                                        "markdown"   => true,
                                                        "opengraph"  => true,
                                                        "remotePods" => true
                                                      })
      end
    end

    context "when admin account is set" do
      before do
        AppConfig.admins.account = "podmin"
      end

      it "adds the admin account username" do
        expect(hash).to include "metadata" => include("adminAccount" => "podmin")
      end
    end

    context "version 2.0" do
      it "provides generic pod data in json" do
        expect(NodeInfoPresenter.new("2.0").as_json.as_json).to eq(
          "version"           => "2.0",
          "software"          => {
            "name"    => "diaspora",
            "version" => AppConfig.version_string
          },
          "protocols"         => ["diaspora"],
          "services"          => {
            "inbound"  => [],
            "outbound" => AppConfig.configured_services.map(&:to_s)
          },
          "openRegistrations" => AppConfig.settings.enable_registrations?,
          "usage"             => {
            "users" => {}
          },
          "metadata"          => {
            "nodeName" => AppConfig.settings.pod_name,
            "xmppChat" => AppConfig.chat.enabled?,
            "camo"     => {
              "markdown"   => AppConfig.privacy.camo.proxy_markdown_images?,
              "opengraph"  => AppConfig.privacy.camo.proxy_opengraph_thumbnails?,
              "remotePods" => AppConfig.privacy.camo.proxy_remote_pod_images?
            }
          }
        )
      end
    end
  end
end
