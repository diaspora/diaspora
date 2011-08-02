# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rails-i18n}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rails I18n Group"]
  s.date = %q{2011-07-18}
  s.description = %q{A set of common locale data and translations to internationalize and/or localize your Rails applications.}
  s.email = %q{rails-i18n@googlegroups.com}
  s.files = ["lib/rails-i18n.rb", "lib/rails_i18n/railtie.rb", "lib/rails_i18n.rb", "rails/locale/hi-IN.yml", "rails/locale/en-AU.yml", "rails/locale/vi.yml", "rails/locale/sr-Latn.yml", "rails/locale/lv.yml", "rails/locale/es-CO.yml", "rails/locale/pl.yml", "rails/locale/nl.yml", "rails/locale/de.yml", "rails/locale/tr.yml", "rails/locale/pt-BR.yml", "rails/locale/mn.yml", "rails/locale/eo.yml", "rails/locale/cy.yml", "rails/locale/en-US.yml", "rails/locale/sw.yml", "rails/locale/ja.yml", "rails/locale/es.yml", "rails/locale/bn-IN.yml", "rails/locale/es-MX.yml", "rails/locale/kn.yml", "rails/locale/fi.yml", "rails/locale/eu.yml", "rails/locale/de-CH.yml", "rails/locale/gl-ES.yml", "rails/locale/ar.yml", "rails/locale/nn.yml", "rails/locale/hi.yml", "rails/locale/zh-TW.yml", "rails/locale/el.yml", "rails/locale/bg.yml", "rails/locale/ko.yml", "rails/locale/rm.yml", "rails/locale/hr.yml", "rails/locale/fr-CH.yml", "rails/locale/da.yml", "rails/locale/fr-CA.yml", "rails/locale/is.yml", "rails/locale/ro.yml", "rails/locale/pt-PT.yml", "rails/locale/nb.yml", "rails/locale/uk.yml", "rails/locale/sr.yml", "rails/locale/lo.yml", "rails/locale/mk.yml", "rails/locale/hu.yml", "rails/locale/sk.yml", "rails/locale/zh-CN.yml", "rails/locale/cs.rb", "rails/locale/es-AR.yml", "rails/locale/en-GB.yml", "rails/locale/fa.yml", "rails/locale/es-CL.yml", "rails/locale/ca.yml", "rails/locale/id.yml", "rails/locale/de-AT.yml", "rails/locale/dsb.yml", "rails/locale/th.rb", "rails/locale/hsb.yml", "rails/locale/it.yml", "rails/locale/gsw-CH.yml", "rails/locale/es-PE.yml", "rails/locale/ru.yml", "rails/locale/sv-SE.yml", "rails/locale/sl.yml", "rails/locale/fr.yml", "rails/locale/et.yml", "rails/locale/he.yml", "rails/locale/bs.yml", "rails/locale/lt.yml", "rails/locale/fur.yml", "README.md", "MIT-LICENSE.txt"]
  s.homepage = %q{http://github.com/svenfuchs/rails-i18n}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{[none]}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Common locale data and translations for Rails i18n.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3"])
  end
end
