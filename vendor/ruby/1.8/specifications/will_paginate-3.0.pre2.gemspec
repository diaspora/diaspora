# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{will_paginate}
  s.version = "3.0.pre2"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mislav Marohni\304\207"]
  s.date = %q{2010-02-05}
  s.description = %q{The will_paginate library provides a simple, yet powerful and extensible API for pagination and rendering of page links in web application templates.}
  s.email = %q{mislav.marohnic@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
  s.files = ["Rakefile", "lib/will_paginate/array.rb", "lib/will_paginate/collection.rb", "lib/will_paginate/core_ext.rb", "lib/will_paginate/deprecation.rb", "lib/will_paginate/finders/active_record.rb", "lib/will_paginate/finders/active_resource.rb", "lib/will_paginate/finders/base.rb", "lib/will_paginate/finders/data_mapper.rb", "lib/will_paginate/finders/sequel.rb", "lib/will_paginate/finders.rb", "lib/will_paginate/railtie.rb", "lib/will_paginate/version.rb", "lib/will_paginate/view_helpers/action_view.rb", "lib/will_paginate/view_helpers/base.rb", "lib/will_paginate/view_helpers/link_renderer.rb", "lib/will_paginate/view_helpers/link_renderer_base.rb", "lib/will_paginate/view_helpers/merb.rb", "lib/will_paginate/view_helpers.rb", "lib/will_paginate.rb", "spec/collection_spec.rb", "spec/console", "spec/console_fixtures.rb", "spec/database.yml", "spec/finders/active_record_spec.rb", "spec/finders/active_resource_spec.rb", "spec/finders/activerecord_test_connector.rb", "spec/finders/data_mapper_spec.rb", "spec/finders/data_mapper_test_connector.rb", "spec/finders/sequel_spec.rb", "spec/finders/sequel_test_connector.rb", "spec/finders_spec.rb", "spec/fixtures/admin.rb", "spec/fixtures/developer.rb", "spec/fixtures/developers_projects.yml", "spec/fixtures/project.rb", "spec/fixtures/projects.yml", "spec/fixtures/replies.yml", "spec/fixtures/reply.rb", "spec/fixtures/schema.rb", "spec/fixtures/topic.rb", "spec/fixtures/topics.yml", "spec/fixtures/user.rb", "spec/fixtures/users.yml", "spec/rcov.opts", "spec/spec.opts", "spec/spec_helper.rb", "spec/tasks.rake", "spec/view_helpers/action_view_spec.rb", "spec/view_helpers/base_spec.rb", "spec/view_helpers/link_renderer_base_spec.rb", "spec/view_helpers/view_example_group.rb", "README.rdoc", "LICENSE", "CHANGELOG.rdoc"]
  s.homepage = %q{http://github.com/mislav/will_paginate/wikis}
  s.rdoc_options = ["--main", "README.rdoc", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Adaptive pagination plugin for web frameworks and other applications}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
