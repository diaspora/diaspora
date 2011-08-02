# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oa-oauth}
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Bleigh", "Erik Michaels-Ober"]
  s.date = %q{2011-05-20}
  s.description = %q{OAuth strategies for OmniAuth.}
  s.email = ["michael@intridea.com", "sferik@gmail.com"]
  s.files = [".gemtest", ".rspec", ".yardopts", "Gemfile", "LICENSE", "README.rdoc", "Rakefile", "autotest/discover.rb", "lib/oa-oauth.rb", "lib/omniauth/oauth.rb", "lib/omniauth/strategies/bitly.rb", "lib/omniauth/strategies/dailymile.rb", "lib/omniauth/strategies/doit.rb", "lib/omniauth/strategies/dopplr.rb", "lib/omniauth/strategies/douban.rb", "lib/omniauth/strategies/evernote.rb", "lib/omniauth/strategies/facebook.rb", "lib/omniauth/strategies/foursquare.rb", "lib/omniauth/strategies/github.rb", "lib/omniauth/strategies/goodreads.rb", "lib/omniauth/strategies/google.rb", "lib/omniauth/strategies/gowalla.rb", "lib/omniauth/strategies/hyves.rb", "lib/omniauth/strategies/identica.rb", "lib/omniauth/strategies/instagram.rb", "lib/omniauth/strategies/instapaper.rb", "lib/omniauth/strategies/linked_in.rb", "lib/omniauth/strategies/mailru.rb", "lib/omniauth/strategies/meetup.rb", "lib/omniauth/strategies/miso.rb", "lib/omniauth/strategies/mixi.rb", "lib/omniauth/strategies/netflix.rb", "lib/omniauth/strategies/oauth.rb", "lib/omniauth/strategies/oauth2.rb", "lib/omniauth/strategies/plurk.rb", "lib/omniauth/strategies/qzone.rb", "lib/omniauth/strategies/rdio.rb", "lib/omniauth/strategies/renren.rb", "lib/omniauth/strategies/salesforce.rb", "lib/omniauth/strategies/smug_mug.rb", "lib/omniauth/strategies/sound_cloud.rb", "lib/omniauth/strategies/t163.rb", "lib/omniauth/strategies/taobao.rb", "lib/omniauth/strategies/teambox.rb", "lib/omniauth/strategies/thirty_seven_signals.rb", "lib/omniauth/strategies/tqq.rb", "lib/omniauth/strategies/trade_me.rb", "lib/omniauth/strategies/trip_it.rb", "lib/omniauth/strategies/tsina.rb", "lib/omniauth/strategies/tsohu.rb", "lib/omniauth/strategies/tumblr.rb", "lib/omniauth/strategies/twitter.rb", "lib/omniauth/strategies/type_pad.rb", "lib/omniauth/strategies/vimeo.rb", "lib/omniauth/strategies/vkontakte.rb", "lib/omniauth/strategies/xauth.rb", "lib/omniauth/strategies/yahoo.rb", "lib/omniauth/strategies/yammer.rb", "lib/omniauth/strategies/you_tube.rb", "lib/omniauth/version.rb", "oa-oauth.gemspec", "spec/fixtures/basecamp_200.xml", "spec/fixtures/campfire_200.json", "spec/omniauth/strategies/bitly_spec.rb", "spec/omniauth/strategies/dailymile_spec.rb", "spec/omniauth/strategies/doit_spec.rb", "spec/omniauth/strategies/dopplr_spec.rb", "spec/omniauth/strategies/douban_spec.rb", "spec/omniauth/strategies/evernote_spec.rb", "spec/omniauth/strategies/facebook_spec.rb", "spec/omniauth/strategies/foursquare_spec.rb", "spec/omniauth/strategies/github_spec.rb", "spec/omniauth/strategies/goodreads_spec.rb", "spec/omniauth/strategies/google_spec.rb", "spec/omniauth/strategies/gowalla_spec.rb", "spec/omniauth/strategies/hyves_spec.rb", "spec/omniauth/strategies/identica_spec.rb", "spec/omniauth/strategies/linked_in_spec.rb", "spec/omniauth/strategies/mailru_spec.rb", "spec/omniauth/strategies/meetup_spec.rb", "spec/omniauth/strategies/miso_spec.rb", "spec/omniauth/strategies/netflix_spec.rb", "spec/omniauth/strategies/oauth2_spec.rb", "spec/omniauth/strategies/oauth_spec.rb", "spec/omniauth/strategies/plurk_spec.rb", "spec/omniauth/strategies/rdio_spec.rb", "spec/omniauth/strategies/salesforce_spec.rb", "spec/omniauth/strategies/smug_mug_spec.rb", "spec/omniauth/strategies/sound_cloud_spec.rb", "spec/omniauth/strategies/t163_spec.rb", "spec/omniauth/strategies/taobao_spec.rb", "spec/omniauth/strategies/teambox_spec.rb", "spec/omniauth/strategies/thirty_seven_signals_spec.rb", "spec/omniauth/strategies/trade_me_spec.rb", "spec/omniauth/strategies/trip_it_spec.rb", "spec/omniauth/strategies/tsina_spec.rb", "spec/omniauth/strategies/tumblr_spec.rb", "spec/omniauth/strategies/twitter_spec.rb", "spec/omniauth/strategies/type_pad_spec.rb", "spec/omniauth/strategies/vimeo_spec.rb", "spec/omniauth/strategies/vkontakte_spec.rb", "spec/omniauth/strategies/yahoo_spec.rb", "spec/omniauth/strategies/yammer_spec.rb", "spec/omniauth/strategies/you_tube_spec.rb", "spec/spec_helper.rb", "spec/support/shared_examples.rb"]
  s.homepage = %q{http://github.com/intridea/omniauth}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{OAuth strategies for OmniAuth.}
  s.test_files = ["spec/fixtures/basecamp_200.xml", "spec/fixtures/campfire_200.json", "spec/omniauth/strategies/bitly_spec.rb", "spec/omniauth/strategies/dailymile_spec.rb", "spec/omniauth/strategies/doit_spec.rb", "spec/omniauth/strategies/dopplr_spec.rb", "spec/omniauth/strategies/douban_spec.rb", "spec/omniauth/strategies/evernote_spec.rb", "spec/omniauth/strategies/facebook_spec.rb", "spec/omniauth/strategies/foursquare_spec.rb", "spec/omniauth/strategies/github_spec.rb", "spec/omniauth/strategies/goodreads_spec.rb", "spec/omniauth/strategies/google_spec.rb", "spec/omniauth/strategies/gowalla_spec.rb", "spec/omniauth/strategies/hyves_spec.rb", "spec/omniauth/strategies/identica_spec.rb", "spec/omniauth/strategies/linked_in_spec.rb", "spec/omniauth/strategies/mailru_spec.rb", "spec/omniauth/strategies/meetup_spec.rb", "spec/omniauth/strategies/miso_spec.rb", "spec/omniauth/strategies/netflix_spec.rb", "spec/omniauth/strategies/oauth2_spec.rb", "spec/omniauth/strategies/oauth_spec.rb", "spec/omniauth/strategies/plurk_spec.rb", "spec/omniauth/strategies/rdio_spec.rb", "spec/omniauth/strategies/salesforce_spec.rb", "spec/omniauth/strategies/smug_mug_spec.rb", "spec/omniauth/strategies/sound_cloud_spec.rb", "spec/omniauth/strategies/t163_spec.rb", "spec/omniauth/strategies/taobao_spec.rb", "spec/omniauth/strategies/teambox_spec.rb", "spec/omniauth/strategies/thirty_seven_signals_spec.rb", "spec/omniauth/strategies/trade_me_spec.rb", "spec/omniauth/strategies/trip_it_spec.rb", "spec/omniauth/strategies/tsina_spec.rb", "spec/omniauth/strategies/tumblr_spec.rb", "spec/omniauth/strategies/twitter_spec.rb", "spec/omniauth/strategies/type_pad_spec.rb", "spec/omniauth/strategies/vimeo_spec.rb", "spec/omniauth/strategies/vkontakte_spec.rb", "spec/omniauth/strategies/yahoo_spec.rb", "spec/omniauth/strategies/yammer_spec.rb", "spec/omniauth/strategies/you_tube_spec.rb", "spec/spec_helper.rb", "spec/support/shared_examples.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.6.1"])
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<multi_xml>, ["~> 0.2.2"])
      s.add_runtime_dependency(%q<oa-core>, ["= 0.2.6"])
      s.add_runtime_dependency(%q<oauth>, ["~> 0.4.0"])
      s.add_runtime_dependency(%q<oauth2>, ["~> 0.4.1"])
      s.add_development_dependency(%q<evernote>, ["~> 0.9"])
      s.add_development_dependency(%q<maruku>, ["~> 0.6"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_development_dependency(%q<rake>, ["~> 0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_development_dependency(%q<webmock>, ["~> 1.6"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<ZenTest>, ["~> 4.5"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.6.1"])
      s.add_dependency(%q<multi_json>, ["~> 1.0.0"])
      s.add_dependency(%q<multi_xml>, ["~> 0.2.2"])
      s.add_dependency(%q<oa-core>, ["= 0.2.6"])
      s.add_dependency(%q<oauth>, ["~> 0.4.0"])
      s.add_dependency(%q<oauth2>, ["~> 0.4.1"])
      s.add_dependency(%q<evernote>, ["~> 0.9"])
      s.add_dependency(%q<maruku>, ["~> 0.6"])
      s.add_dependency(%q<rack-test>, ["~> 0.5"])
      s.add_dependency(%q<rake>, ["~> 0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.5"])
      s.add_dependency(%q<simplecov>, ["~> 0.4"])
      s.add_dependency(%q<webmock>, ["~> 1.6"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<ZenTest>, ["~> 4.5"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.6.1"])
    s.add_dependency(%q<multi_json>, ["~> 1.0.0"])
    s.add_dependency(%q<multi_xml>, ["~> 0.2.2"])
    s.add_dependency(%q<oa-core>, ["= 0.2.6"])
    s.add_dependency(%q<oauth>, ["~> 0.4.0"])
    s.add_dependency(%q<oauth2>, ["~> 0.4.1"])
    s.add_dependency(%q<evernote>, ["~> 0.9"])
    s.add_dependency(%q<maruku>, ["~> 0.6"])
    s.add_dependency(%q<rack-test>, ["~> 0.5"])
    s.add_dependency(%q<rake>, ["~> 0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.5"])
    s.add_dependency(%q<simplecov>, ["~> 0.4"])
    s.add_dependency(%q<webmock>, ["~> 1.6"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<ZenTest>, ["~> 4.5"])
  end
end
