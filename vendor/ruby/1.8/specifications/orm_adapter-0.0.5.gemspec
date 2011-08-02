# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{orm_adapter}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ian White", "Jose Valim"]
  s.date = %q{2011-05-09}
  s.description = %q{Provides a single point of entry for using basic features of ruby ORMs}
  s.email = %q{ian.w.white@gmail.com}
  s.files = [".gitignore", "Gemfile", "Gemfile.lock.development", "History.txt", "LICENSE", "README.rdoc", "Rakefile", "lib/orm_adapter.rb", "lib/orm_adapter/adapters/active_record.rb", "lib/orm_adapter/adapters/data_mapper.rb", "lib/orm_adapter/adapters/mongo_mapper.rb", "lib/orm_adapter/adapters/mongoid.rb", "lib/orm_adapter/base.rb", "lib/orm_adapter/to_adapter.rb", "lib/orm_adapter/version.rb", "orm_adapter.gemspec", "spec/orm_adapter/adapters/active_record_spec.rb", "spec/orm_adapter/adapters/data_mapper_spec.rb", "spec/orm_adapter/adapters/mongo_mapper_spec.rb", "spec/orm_adapter/adapters/mongoid_spec.rb", "spec/orm_adapter/base_spec.rb", "spec/orm_adapter/example_app_shared.rb", "spec/orm_adapter_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/ianwhite/orm_adapter}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{orm_adapter}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{orm_adapter provides a single point of entry for using basic features of popular ruby ORMs.  Its target audience is gem authors who want to support many ruby ORMs.}
  s.test_files = ["spec/orm_adapter/adapters/active_record_spec.rb", "spec/orm_adapter/adapters/data_mapper_spec.rb", "spec/orm_adapter/adapters/mongo_mapper_spec.rb", "spec/orm_adapter/adapters/mongoid_spec.rb", "spec/orm_adapter/base_spec.rb", "spec/orm_adapter/example_app_shared.rb", "spec/orm_adapter_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<git>, [">= 1.2.5"])
      s.add_development_dependency(%q<yard>, [">= 0.6.0"])
      s.add_development_dependency(%q<rake>, [">= 0.8.7"])
      s.add_development_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_development_dependency(%q<mongoid>, [">= 2.0.0.beta.20"])
      s.add_development_dependency(%q<mongo_mapper>, [">= 0.9.0"])
      s.add_development_dependency(%q<bson_ext>, [">= 1.3.0"])
      s.add_development_dependency(%q<rspec>, [">= 2.4.0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
      s.add_development_dependency(%q<datamapper>, [">= 1.0"])
      s.add_development_dependency(%q<dm-sqlite-adapter>, [">= 1.0"])
      s.add_development_dependency(%q<dm-active_model>, [">= 1.0"])
    else
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<git>, [">= 1.2.5"])
      s.add_dependency(%q<yard>, [">= 0.6.0"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
      s.add_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_dependency(%q<mongoid>, [">= 2.0.0.beta.20"])
      s.add_dependency(%q<mongo_mapper>, [">= 0.9.0"])
      s.add_dependency(%q<bson_ext>, [">= 1.3.0"])
      s.add_dependency(%q<rspec>, [">= 2.4.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
      s.add_dependency(%q<datamapper>, [">= 1.0"])
      s.add_dependency(%q<dm-sqlite-adapter>, [">= 1.0"])
      s.add_dependency(%q<dm-active_model>, [">= 1.0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<git>, [">= 1.2.5"])
    s.add_dependency(%q<yard>, [">= 0.6.0"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
    s.add_dependency(%q<activerecord>, [">= 3.0.0"])
    s.add_dependency(%q<mongoid>, [">= 2.0.0.beta.20"])
    s.add_dependency(%q<mongo_mapper>, [">= 0.9.0"])
    s.add_dependency(%q<bson_ext>, [">= 1.3.0"])
    s.add_dependency(%q<rspec>, [">= 2.4.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
    s.add_dependency(%q<datamapper>, [">= 1.0"])
    s.add_dependency(%q<dm-sqlite-adapter>, [">= 1.0"])
    s.add_dependency(%q<dm-active_model>, [">= 1.0"])
  end
end
