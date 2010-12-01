# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{i18n}
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sven Fuchs", "Joshua Harvey", "Matt Aimonetti", "Stephan Soller", "Saimon Moore"]
  s.date = %q{2010-10-26}
  s.description = %q{New wave Internationalization support for Ruby.}
  s.email = %q{rails-i18n@googlegroups.com}
  s.files = ["lib/i18n.rb", "lib/i18n/backend.rb", "lib/i18n/backend/active_record.rb", "lib/i18n/backend/active_record/missing.rb", "lib/i18n/backend/active_record/store_procs.rb", "lib/i18n/backend/active_record/translation.rb", "lib/i18n/backend/base.rb", "lib/i18n/backend/cache.rb", "lib/i18n/backend/cascade.rb", "lib/i18n/backend/chain.rb", "lib/i18n/backend/cldr.rb", "lib/i18n/backend/fallbacks.rb", "lib/i18n/backend/flatten.rb", "lib/i18n/backend/gettext.rb", "lib/i18n/backend/interpolation_compiler.rb", "lib/i18n/backend/key_value.rb", "lib/i18n/backend/memoize.rb", "lib/i18n/backend/metadata.rb", "lib/i18n/backend/pluralization.rb", "lib/i18n/backend/simple.rb", "lib/i18n/backend/transliterator.rb", "lib/i18n/config.rb", "lib/i18n/core_ext/hash.rb", "lib/i18n/core_ext/string/interpolate.rb", "lib/i18n/exceptions.rb", "lib/i18n/gettext.rb", "lib/i18n/gettext/helpers.rb", "lib/i18n/gettext/po_parser.rb", "lib/i18n/locale.rb", "lib/i18n/locale/fallbacks.rb", "lib/i18n/locale/tag.rb", "lib/i18n/locale/tag/parents.rb", "lib/i18n/locale/tag/rfc4646.rb", "lib/i18n/locale/tag/simple.rb", "lib/i18n/version.rb", "README.textile", "MIT-LICENSE", "CHANGELOG.textile"]
  s.homepage = %q{http://github.com/svenfuchs/i18n}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{[none]}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{New wave Internationalization support for Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
