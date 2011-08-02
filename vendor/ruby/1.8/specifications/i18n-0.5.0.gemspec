# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{i18n}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sven Fuchs", "Joshua Harvey", "Matt Aimonetti", "Stephan Soller", "Saimon Moore"]
  s.date = %q{2010-11-29}
  s.description = %q{New wave Internationalization support for Ruby.}
  s.email = %q{rails-i18n@googlegroups.com}
  s.files = ["ci/Gemfile.no-rails", "ci/Gemfile.no-rails.lock", "ci/Gemfile.rails-2.3.x", "ci/Gemfile.rails-2.3.x.lock", "ci/Gemfile.rails-3.x", "ci/Gemfile.rails-3.x.lock", "lib/i18n/backend/base.rb", "lib/i18n/backend/cache.rb", "lib/i18n/backend/cascade.rb", "lib/i18n/backend/chain.rb", "lib/i18n/backend/fallbacks.rb", "lib/i18n/backend/flatten.rb", "lib/i18n/backend/gettext.rb", "lib/i18n/backend/interpolation_compiler.rb", "lib/i18n/backend/key_value.rb", "lib/i18n/backend/memoize.rb", "lib/i18n/backend/metadata.rb", "lib/i18n/backend/pluralization.rb", "lib/i18n/backend/simple.rb", "lib/i18n/backend/transliterator.rb", "lib/i18n/backend.rb", "lib/i18n/config.rb", "lib/i18n/core_ext/hash.rb", "lib/i18n/core_ext/kernel/surpress_warnings.rb", "lib/i18n/core_ext/string/interpolate.rb", "lib/i18n/exceptions.rb", "lib/i18n/gettext/helpers.rb", "lib/i18n/gettext/po_parser.rb", "lib/i18n/gettext.rb", "lib/i18n/interpolate/ruby.rb", "lib/i18n/locale/fallbacks.rb", "lib/i18n/locale/tag/parents.rb", "lib/i18n/locale/tag/rfc4646.rb", "lib/i18n/locale/tag/simple.rb", "lib/i18n/locale/tag.rb", "lib/i18n/locale.rb", "lib/i18n/tests/basics.rb", "lib/i18n/tests/defaults.rb", "lib/i18n/tests/interpolation.rb", "lib/i18n/tests/link.rb", "lib/i18n/tests/localization/date.rb", "lib/i18n/tests/localization/date_time.rb", "lib/i18n/tests/localization/procs.rb", "lib/i18n/tests/localization/time.rb", "lib/i18n/tests/localization.rb", "lib/i18n/tests/lookup.rb", "lib/i18n/tests/pluralization.rb", "lib/i18n/tests/procs.rb", "lib/i18n/tests.rb", "lib/i18n/version.rb", "lib/i18n.rb", "test/all.rb", "test/api/all_features_test.rb", "test/api/cascade_test.rb", "test/api/chain_test.rb", "test/api/fallbacks_test.rb", "test/api/key_value_test.rb", "test/api/memoize_test.rb", "test/api/pluralization_test.rb", "test/api/simple_test.rb", "test/backend/cache_test.rb", "test/backend/cascade_test.rb", "test/backend/chain_test.rb", "test/backend/exceptions_test.rb", "test/backend/fallbacks_test.rb", "test/backend/interpolation_compiler_test.rb", "test/backend/key_value_test.rb", "test/backend/memoize_test.rb", "test/backend/metadata_test.rb", "test/backend/pluralization_test.rb", "test/backend/simple_test.rb", "test/backend/transliterator_test.rb", "test/core_ext/hash_test.rb", "test/core_ext/string/interpolate_test.rb", "test/gettext/api_test.rb", "test/gettext/backend_test.rb", "test/i18n/exceptions_test.rb", "test/i18n/interpolate_test.rb", "test/i18n/load_path_test.rb", "test/i18n_test.rb", "test/locale/fallbacks_test.rb", "test/locale/tag/rfc4646_test.rb", "test/locale/tag/simple_test.rb", "test/run_all.rb", "test/test_data/locales/de.po", "test/test_data/locales/en.rb", "test/test_data/locales/en.yml", "test/test_data/locales/invalid/empty.yml", "test/test_data/locales/plurals.rb", "test/test_helper.rb", "README.textile", "MIT-LICENSE", "CHANGELOG.textile"]
  s.homepage = %q{http://github.com/svenfuchs/i18n}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{[none]}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{New wave Internationalization support for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<activesupport>, ["~> 3.0.0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<test_declarative>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<test_declarative>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<test_declarative>, [">= 0"])
  end
end
