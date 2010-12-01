# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{twitter}
  s.version = "0.9.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Nunemaker", "Wynn Netherland", "Erik Michaels-Ober"]
  s.date = %q{2010-09-25}
  s.description = %q{Ruby wrapper for the Twitter API}
  s.email = ["nunemaker@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = [".autotest", ".gitignore", "Gemfile", "Gemfile.lock", "HISTORY.rdoc", "License", "Notes", "README.rdoc", "Rakefile", "examples/connect.rb", "examples/friends_followers_rank.rb", "examples/friendship_existence.rb", "examples/helpers/config_store.rb", "examples/ids.rb", "examples/lists.rb", "examples/oauth.rb", "examples/search.rb", "examples/timeline.rb", "examples/unauthorized.rb", "examples/update.rb", "examples/user.rb", "lib/twitter.rb", "lib/twitter/base.rb", "lib/twitter/geo.rb", "lib/twitter/local_trends.rb", "lib/twitter/oauth.rb", "lib/twitter/request.rb", "lib/twitter/search.rb", "lib/twitter/trends.rb", "lib/twitter/version.rb", "test/fixtures/blocking.json", "test/fixtures/firehose.json", "test/fixtures/follower_ids.json", "test/fixtures/followers.json", "test/fixtures/friend_ids.json", "test/fixtures/friends_timeline.json", "test/fixtures/friendship.json", "test/fixtures/friendship_exists.json", "test/fixtures/geo_place.json", "test/fixtures/geo_reverse_geocode.json", "test/fixtures/geo_reverse_geocode_granularity.json", "test/fixtures/geo_reverse_geocode_limit.json", "test/fixtures/geo_search.json", "test/fixtures/geo_search_ip_address.json", "test/fixtures/geo_search_query.json", "test/fixtures/home_timeline.json", "test/fixtures/ids.json", "test/fixtures/list.json", "test/fixtures/list_statuses.json", "test/fixtures/list_statuses_1_1.json", "test/fixtures/list_statuses_2_1.json", "test/fixtures/list_subscriptions.json", "test/fixtures/list_users.json", "test/fixtures/lists.json", "test/fixtures/memberships.json", "test/fixtures/mentions.json", "test/fixtures/not_found.json", "test/fixtures/people_search.json", "test/fixtures/rate_limit_exceeded.json", "test/fixtures/report_spam.json", "test/fixtures/retweet.json", "test/fixtures/retweeted_by_me.json", "test/fixtures/retweeted_to_me.json", "test/fixtures/retweeters_of_tweet.json", "test/fixtures/retweets.json", "test/fixtures/retweets_of_me.json", "test/fixtures/sample-image.png", "test/fixtures/saved_search.json", "test/fixtures/saved_searches.json", "test/fixtures/search.json", "test/fixtures/search_from_jnunemaker.json", "test/fixtures/search_milk_cheeze.json", "test/fixtures/status.json", "test/fixtures/status_show.json", "test/fixtures/trends_available.json", "test/fixtures/trends_current.json", "test/fixtures/trends_current_exclude.json", "test/fixtures/trends_daily.json", "test/fixtures/trends_daily_date.json", "test/fixtures/trends_daily_exclude.json", "test/fixtures/trends_location.json", "test/fixtures/trends_weekly.json", "test/fixtures/trends_weekly_date.json", "test/fixtures/trends_weekly_exclude.json", "test/fixtures/unauthorized.json", "test/fixtures/update_profile_background_image.json", "test/fixtures/update_profile_image.json", "test/fixtures/user.json", "test/fixtures/user_timeline.json", "test/fixtures/users.json", "test/test_helper.rb", "test/twitter/base_test.rb", "test/twitter/geo_test.rb", "test/twitter/oauth_test.rb", "test/twitter/request_test.rb", "test/twitter/search_test.rb", "test/twitter/trends_test.rb", "test/twitter_test.rb", "twitter.gemspec", "website/css/common.css", "website/images/terminal_output.png", "website/index.html"]
  s.homepage = %q{http://rubygems.org/gems/twitter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{twitter}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby wrapper for the Twitter API}
  s.test_files = ["test/fixtures/blocking.json", "test/fixtures/firehose.json", "test/fixtures/follower_ids.json", "test/fixtures/followers.json", "test/fixtures/friend_ids.json", "test/fixtures/friends_timeline.json", "test/fixtures/friendship.json", "test/fixtures/friendship_exists.json", "test/fixtures/geo_place.json", "test/fixtures/geo_reverse_geocode.json", "test/fixtures/geo_reverse_geocode_granularity.json", "test/fixtures/geo_reverse_geocode_limit.json", "test/fixtures/geo_search.json", "test/fixtures/geo_search_ip_address.json", "test/fixtures/geo_search_query.json", "test/fixtures/home_timeline.json", "test/fixtures/ids.json", "test/fixtures/list.json", "test/fixtures/list_statuses.json", "test/fixtures/list_statuses_1_1.json", "test/fixtures/list_statuses_2_1.json", "test/fixtures/list_subscriptions.json", "test/fixtures/list_users.json", "test/fixtures/lists.json", "test/fixtures/memberships.json", "test/fixtures/mentions.json", "test/fixtures/not_found.json", "test/fixtures/people_search.json", "test/fixtures/rate_limit_exceeded.json", "test/fixtures/report_spam.json", "test/fixtures/retweet.json", "test/fixtures/retweeted_by_me.json", "test/fixtures/retweeted_to_me.json", "test/fixtures/retweeters_of_tweet.json", "test/fixtures/retweets.json", "test/fixtures/retweets_of_me.json", "test/fixtures/sample-image.png", "test/fixtures/saved_search.json", "test/fixtures/saved_searches.json", "test/fixtures/search.json", "test/fixtures/search_from_jnunemaker.json", "test/fixtures/search_milk_cheeze.json", "test/fixtures/status.json", "test/fixtures/status_show.json", "test/fixtures/trends_available.json", "test/fixtures/trends_current.json", "test/fixtures/trends_current_exclude.json", "test/fixtures/trends_daily.json", "test/fixtures/trends_daily_date.json", "test/fixtures/trends_daily_exclude.json", "test/fixtures/trends_location.json", "test/fixtures/trends_weekly.json", "test/fixtures/trends_weekly_date.json", "test/fixtures/trends_weekly_exclude.json", "test/fixtures/unauthorized.json", "test/fixtures/update_profile_background_image.json", "test/fixtures/update_profile_image.json", "test/fixtures/user.json", "test/fixtures/user_timeline.json", "test/fixtures/users.json", "test/test_helper.rb", "test/twitter/base_test.rb", "test/twitter/geo_test.rb", "test/twitter/oauth_test.rb", "test/twitter/request_test.rb", "test/twitter/search_test.rb", "test/twitter/trends_test.rb", "test/twitter_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9.8"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_runtime_dependency(%q<hashie>, ["~> 0.4.0"])
      s.add_runtime_dependency(%q<httparty>, ["~> 0.6.1"])
      s.add_runtime_dependency(%q<oauth>, ["~> 0.4.3"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 0.0.4"])
    else
      s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_dependency(%q<mocha>, ["~> 0.9.8"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
      s.add_dependency(%q<hashie>, ["~> 0.4.0"])
      s.add_dependency(%q<httparty>, ["~> 0.6.1"])
      s.add_dependency(%q<oauth>, ["~> 0.4.3"])
      s.add_dependency(%q<multi_json>, ["~> 0.0.4"])
    end
  else
    s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
    s.add_dependency(%q<mocha>, ["~> 0.9.8"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.3"])
    s.add_dependency(%q<hashie>, ["~> 0.4.0"])
    s.add_dependency(%q<httparty>, ["~> 0.6.1"])
    s.add_dependency(%q<oauth>, ["~> 0.4.3"])
    s.add_dependency(%q<multi_json>, ["~> 0.0.4"])
  end
end
