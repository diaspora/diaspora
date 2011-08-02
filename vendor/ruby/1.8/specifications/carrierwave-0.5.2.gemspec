# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{carrierwave}
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Nicklas"]
  s.date = %q{2011-02-18}
  s.description = %q{Upload files in your Ruby applications, map them to a range of ORMs, store them on different backends.}
  s.email = ["jonas.nicklas@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["lib/carrierwave/compatibility/paperclip.rb", "lib/carrierwave/locale/en.yml", "lib/carrierwave/mount.rb", "lib/carrierwave/orm/activerecord.rb", "lib/carrierwave/orm/datamapper.rb", "lib/carrierwave/orm/mongoid.rb", "lib/carrierwave/orm/sequel.rb", "lib/carrierwave/processing/image_science.rb", "lib/carrierwave/processing/mini_magick.rb", "lib/carrierwave/processing/rmagick.rb", "lib/carrierwave/sanitized_file.rb", "lib/carrierwave/storage/abstract.rb", "lib/carrierwave/storage/cloud_files.rb", "lib/carrierwave/storage/file.rb", "lib/carrierwave/storage/grid_fs.rb", "lib/carrierwave/storage/right_s3.rb", "lib/carrierwave/storage/s3.rb", "lib/carrierwave/test/matchers.rb", "lib/carrierwave/uploader/cache.rb", "lib/carrierwave/uploader/callbacks.rb", "lib/carrierwave/uploader/configuration.rb", "lib/carrierwave/uploader/default_url.rb", "lib/carrierwave/uploader/download.rb", "lib/carrierwave/uploader/extension_whitelist.rb", "lib/carrierwave/uploader/mountable.rb", "lib/carrierwave/uploader/processing.rb", "lib/carrierwave/uploader/proxy.rb", "lib/carrierwave/uploader/remove.rb", "lib/carrierwave/uploader/store.rb", "lib/carrierwave/uploader/url.rb", "lib/carrierwave/uploader/versions.rb", "lib/carrierwave/uploader.rb", "lib/carrierwave/validations/active_model.rb", "lib/carrierwave/version.rb", "lib/carrierwave.rb", "lib/generators/templates/uploader.rb", "lib/generators/uploader_generator.rb", "README.rdoc"]
  s.homepage = %q{http://carrierwave.rubyforge.org}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{carrierwave}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby file upload library}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_development_dependency(%q<rails>, ["~> 3.0"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3"])
      s.add_development_dependency(%q<fog>, ["~> 0.4"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<dm-core>, [">= 0"])
      s.add_development_dependency(%q<dm-validations>, [">= 0"])
      s.add_development_dependency(%q<dm-migrations>, [">= 0"])
      s.add_development_dependency(%q<dm-sqlite-adapter>, [">= 0"])
      s.add_development_dependency(%q<sequel>, [">= 0"])
      s.add_development_dependency(%q<rmagick>, [">= 0"])
      s.add_development_dependency(%q<RubyInline>, [">= 0"])
      s.add_development_dependency(%q<image_science>, [">= 0"])
      s.add_development_dependency(%q<mini_magick>, ["~> 2.3"])
      s.add_development_dependency(%q<bson_ext>, ["= 1.1.1"])
      s.add_development_dependency(%q<mongoid>, ["= 2.0.0.beta.19"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<cloudfiles>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0"])
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<rspec>, ["~> 1.3"])
      s.add_dependency(%q<fog>, ["~> 0.4"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<dm-core>, [">= 0"])
      s.add_dependency(%q<dm-validations>, [">= 0"])
      s.add_dependency(%q<dm-migrations>, [">= 0"])
      s.add_dependency(%q<dm-sqlite-adapter>, [">= 0"])
      s.add_dependency(%q<sequel>, [">= 0"])
      s.add_dependency(%q<rmagick>, [">= 0"])
      s.add_dependency(%q<RubyInline>, [">= 0"])
      s.add_dependency(%q<image_science>, [">= 0"])
      s.add_dependency(%q<mini_magick>, ["~> 2.3"])
      s.add_dependency(%q<bson_ext>, ["= 1.1.1"])
      s.add_dependency(%q<mongoid>, ["= 2.0.0.beta.19"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<cloudfiles>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0"])
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<rspec>, ["~> 1.3"])
    s.add_dependency(%q<fog>, ["~> 0.4"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<dm-core>, [">= 0"])
    s.add_dependency(%q<dm-validations>, [">= 0"])
    s.add_dependency(%q<dm-migrations>, [">= 0"])
    s.add_dependency(%q<dm-sqlite-adapter>, [">= 0"])
    s.add_dependency(%q<sequel>, [">= 0"])
    s.add_dependency(%q<rmagick>, [">= 0"])
    s.add_dependency(%q<RubyInline>, [">= 0"])
    s.add_dependency(%q<image_science>, [">= 0"])
    s.add_dependency(%q<mini_magick>, ["~> 2.3"])
    s.add_dependency(%q<bson_ext>, ["= 1.1.1"])
    s.add_dependency(%q<mongoid>, ["= 2.0.0.beta.19"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<cloudfiles>, [">= 0"])
  end
end
