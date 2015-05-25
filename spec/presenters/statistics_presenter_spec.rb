require "spec_helper"

describe StatisticsPresenter do
  before do
    @presenter = StatisticsPresenter.new
  end

  describe "#as_json" do
    it "works" do
      expect(@presenter.as_json).to be_present
      expect(@presenter.as_json).to be_a Hash
    end
  end

  describe "#statistics contents" do
    before do
      AppConfig.privacy.statistics.user_counts = false
      AppConfig.privacy.statistics.post_counts = false
      AppConfig.privacy.statistics.comment_counts = false
    end

    it "provides generic pod data in json" do
      expect(@presenter.as_json).to eq(
        "name"               => AppConfig.settings.pod_name,
        "network"            => "Diaspora",
        "version"            => AppConfig.version_string,
        "registrations_open" => AppConfig.settings.enable_registrations?,
        "services"           => ["facebook"],
        "facebook"           => true,
        "tumblr"             => false,
        "twitter"            => false,
        "wordpress"          => false
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

      it "provides services in json" do
        expect(@presenter.as_json).to eq(
          "name"               => AppConfig.settings.pod_name,
          "network"            => "Diaspora",
          "version"            => AppConfig.version_string,
          "registrations_open" => AppConfig.settings.enable_registrations?,
          "services"           => %w(twitter facebook),
          "facebook"           => true,
          "twitter"            => true,
          "tumblr"             => false,
          "wordpress"          => false
        )
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

      it "provides services in json" do
        expect(@presenter.as_json).to eq(
          "name"               => AppConfig.settings.pod_name,
          "network"            => "Diaspora",
          "version"            => AppConfig.version_string,
          "registrations_open" => AppConfig.settings.enable_registrations?,
          "services"           => ["twitter"],
          "facebook"           => false,
          "twitter"            => true,
          "tumblr"             => false,
          "wordpress"          => false
        )
      end
    end

    context "when counts are enabled" do
      before do
        AppConfig.privacy.statistics.user_counts = true
        AppConfig.privacy.statistics.post_counts = true
        AppConfig.privacy.statistics.comment_counts = true
      end

      it "provides generic pod data and counts in json" do
        expect(@presenter.as_json).to eq(
          "name"                  => AppConfig.settings.pod_name,
          "network"               => "Diaspora",
          "version"               => AppConfig.version_string,
          "registrations_open"    => AppConfig.settings.enable_registrations?,
          "total_users"           => User.active.count,
          "active_users_halfyear" => User.halfyear_actives.count,
          "active_users_monthly"  => User.monthly_actives.count,
          "local_posts"           => @presenter.local_posts,
          "local_comments"        => @presenter.local_comments,
          "services"              => ["facebook"],
          "facebook"              => true,
          "twitter"               => false,
          "tumblr"                => false,
          "wordpress"             => false
        )
      end
    end

    context "when registrations are closed" do
      before do
        AppConfig.settings.enable_registrations = false
      end

      it "should mark open_registrations to be false" do
        expect(@presenter.open_registrations?).to be false
      end
    end
  end
end
