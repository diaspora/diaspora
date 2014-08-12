require 'spec_helper'

describe StatisticsPresenter do
  before do
    @presenter = StatisticsPresenter.new
  end

  describe '#as_json' do
    it 'works' do
      @presenter.as_json.should be_present
      @presenter.as_json.should be_a Hash
    end
  end

  describe '#statistics contents' do

    it 'provides generic pod data in json' do
      AppConfig.privacy.statistics.user_counts = false
      AppConfig.privacy.statistics.post_counts = false
      AppConfig.privacy.statistics.comment_counts = false
      AppConfig.services = {"facebook" => nil}
      @presenter.as_json.should == {
        "name" => AppConfig.settings.pod_name,
        "version" => AppConfig.version_string,
        "registrations_open" => AppConfig.settings.enable_registrations,
        "facebook" => false
      }
    end
    
    context 'when services are enabled' do
      before do
        AppConfig.privacy.statistics.user_counts = true
        AppConfig.privacy.statistics.post_counts = true
        AppConfig.privacy.statistics.comment_counts = true
        AppConfig.services = {
          "facebook" => {"enable" => true}, 
          "twitter" => {"enable" => true}, 
          "wordpress" => {"enable" => false},
          "tumblr" => {"enable" => false}
        }
      end

      it 'provides generic pod data and counts in json' do
        @presenter.as_json.should == {
          "name" => AppConfig.settings.pod_name,
          "version" => AppConfig.version_string,
          "registrations_open" => AppConfig.settings.enable_registrations,
          "total_users" => User.count,
          "active_users_halfyear" => User.halfyear_actives.count,
          "active_users_monthly" => User.monthly_actives.count,
          "local_posts" => @presenter.local_posts,
          "local_comments" => @presenter.local_comments,
          "facebook" => true,
          "twitter" => true,
          "tumblr" => false,
          "wordpress" => false
        }
      end
    end

  end

end
