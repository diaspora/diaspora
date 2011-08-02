# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capybara}
  s.version = "0.3.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Nicklas"]
  s.date = %q{2010-07-03}
  s.description = %q{Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website}
  s.email = ["jonas.nicklas@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["lib/capybara/cucumber.rb", "lib/capybara/driver/base.rb", "lib/capybara/driver/celerity_driver.rb", "lib/capybara/driver/culerity_driver.rb", "lib/capybara/driver/rack_test_driver.rb", "lib/capybara/driver/selenium_driver.rb", "lib/capybara/dsl.rb", "lib/capybara/node.rb", "lib/capybara/rails.rb", "lib/capybara/save_and_open_page.rb", "lib/capybara/searchable.rb", "lib/capybara/server.rb", "lib/capybara/session.rb", "lib/capybara/spec/driver.rb", "lib/capybara/spec/fixtures/capybara.jpg", "lib/capybara/spec/fixtures/test_file.txt", "lib/capybara/spec/public/jquery-ui.js", "lib/capybara/spec/public/jquery.js", "lib/capybara/spec/public/test.js", "lib/capybara/spec/session/all_spec.rb", "lib/capybara/spec/session/attach_file_spec.rb", "lib/capybara/spec/session/check_spec.rb", "lib/capybara/spec/session/choose_spec.rb", "lib/capybara/spec/session/click_button_spec.rb", "lib/capybara/spec/session/click_link_spec.rb", "lib/capybara/spec/session/click_spec.rb", "lib/capybara/spec/session/current_url_spec.rb", "lib/capybara/spec/session/fill_in_spec.rb", "lib/capybara/spec/session/find_button_spec.rb", "lib/capybara/spec/session/find_by_id_spec.rb", "lib/capybara/spec/session/find_field_spec.rb", "lib/capybara/spec/session/find_link_spec.rb", "lib/capybara/spec/session/find_spec.rb", "lib/capybara/spec/session/has_button_spec.rb", "lib/capybara/spec/session/has_content_spec.rb", "lib/capybara/spec/session/has_css_spec.rb", "lib/capybara/spec/session/has_field_spec.rb", "lib/capybara/spec/session/has_link_spec.rb", "lib/capybara/spec/session/has_select_spec.rb", "lib/capybara/spec/session/has_table_spec.rb", "lib/capybara/spec/session/has_xpath_spec.rb", "lib/capybara/spec/session/headers.rb", "lib/capybara/spec/session/javascript.rb", "lib/capybara/spec/session/locate_spec.rb", "lib/capybara/spec/session/response_code.rb", "lib/capybara/spec/session/select_spec.rb", "lib/capybara/spec/session/uncheck_spec.rb", "lib/capybara/spec/session/unselect_spec.rb", "lib/capybara/spec/session/within_spec.rb", "lib/capybara/spec/session.rb", "lib/capybara/spec/test_app.rb", "lib/capybara/spec/views/buttons.erb", "lib/capybara/spec/views/fieldsets.erb", "lib/capybara/spec/views/form.erb", "lib/capybara/spec/views/frame_one.erb", "lib/capybara/spec/views/frame_two.erb", "lib/capybara/spec/views/postback.erb", "lib/capybara/spec/views/tables.erb", "lib/capybara/spec/views/with_html.erb", "lib/capybara/spec/views/with_js.erb", "lib/capybara/spec/views/with_scope.erb", "lib/capybara/spec/views/with_simple_html.erb", "lib/capybara/spec/views/within_frames.erb", "lib/capybara/version.rb", "lib/capybara/wait_until.rb", "lib/capybara/xpath.rb", "lib/capybara.rb", "spec/capybara_spec.rb", "spec/driver/celerity_driver_spec.rb", "spec/driver/culerity_driver_spec.rb", "spec/driver/rack_test_driver_spec.rb", "spec/driver/remote_culerity_driver_spec.rb", "spec/driver/remote_selenium_driver_spec.rb", "spec/driver/selenium_driver_spec.rb", "spec/dsl_spec.rb", "spec/save_and_open_page_spec.rb", "spec/searchable_spec.rb", "spec/server_spec.rb", "spec/session/celerity_session_spec.rb", "spec/session/culerity_session_spec.rb", "spec/session/rack_test_session_spec.rb", "spec/session/selenium_session_spec.rb", "spec/spec_helper.rb", "spec/wait_until_spec.rb", "spec/xpath_spec.rb", "README.rdoc", "History.txt"]
  s.homepage = %q{http://github.com/jnicklas/capybara}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{capybara}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_runtime_dependency(%q<culerity>, [">= 0.2.4"])
      s.add_runtime_dependency(%q<selenium-webdriver>, [">= 0.0.3"])
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rack-test>, [">= 0.5.4"])
      s.add_development_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<launchy>, [">= 0.3.5"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<culerity>, [">= 0.2.4"])
      s.add_dependency(%q<selenium-webdriver>, [">= 0.0.3"])
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<rack-test>, [">= 0.5.4"])
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<launchy>, [">= 0.3.5"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<culerity>, [">= 0.2.4"])
    s.add_dependency(%q<selenium-webdriver>, [">= 0.0.3"])
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<rack-test>, [">= 0.5.4"])
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<launchy>, [">= 0.3.5"])
  end
end
