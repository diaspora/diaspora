# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{selenium-webdriver}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jari Bakken"]
  s.date = %q{2010-11-11}
  s.description = %q{WebDriver is a tool for writing automated tests of websites. It aims to mimic the behaviour of a real user, and as such interacts with the HTML of the application.}
  s.email = %q{jari.bakken@gmail.com}
  s.files = ["lib/selenium-client.rb", "lib/selenium-webdriver.rb", "lib/selenium/client.rb", "lib/selenium/server.rb", "lib/selenium/webdriver.rb", "lib/selenium/client/base.rb", "lib/selenium/client/driver.rb", "lib/selenium/client/errors.rb", "lib/selenium/client/extensions.rb", "lib/selenium/client/idiomatic.rb", "lib/selenium/client/javascript_expression_builder.rb", "lib/selenium/client/legacy_driver.rb", "lib/selenium/client/protocol.rb", "lib/selenium/client/selenium_helper.rb", "lib/selenium/client/javascript_frameworks/jquery.rb", "lib/selenium/client/javascript_frameworks/prototype.rb", "lib/selenium/rake/server_task.rb", "lib/selenium/webdriver/android.rb", "lib/selenium/webdriver/chrome.rb", "lib/selenium/webdriver/common.rb", "lib/selenium/webdriver/firefox.rb", "lib/selenium/webdriver/ie.rb", "lib/selenium/webdriver/iphone.rb", "lib/selenium/webdriver/remote.rb", "lib/selenium/webdriver/android/bridge.rb", "lib/selenium/webdriver/chrome/bridge.rb", "lib/selenium/webdriver/chrome/command_executor.rb", "lib/selenium/webdriver/chrome/extension.zip", "lib/selenium/webdriver/chrome/launcher.rb", "lib/selenium/webdriver/common/bridge_helper.rb", "lib/selenium/webdriver/common/driver.rb", "lib/selenium/webdriver/common/element.rb", "lib/selenium/webdriver/common/error.rb", "lib/selenium/webdriver/common/file_reaper.rb", "lib/selenium/webdriver/common/find.rb", "lib/selenium/webdriver/common/keys.rb", "lib/selenium/webdriver/common/navigation.rb", "lib/selenium/webdriver/common/options.rb", "lib/selenium/webdriver/common/platform.rb", "lib/selenium/webdriver/common/proxy.rb", "lib/selenium/webdriver/common/socket_poller.rb", "lib/selenium/webdriver/common/target_locator.rb", "lib/selenium/webdriver/common/timeouts.rb", "lib/selenium/webdriver/common/wait.rb", "lib/selenium/webdriver/common/zipper.rb", "lib/selenium/webdriver/common/core_ext/dir.rb", "lib/selenium/webdriver/common/core_ext/string.rb", "lib/selenium/webdriver/common/driver_extensions/rotatable.rb", "lib/selenium/webdriver/common/driver_extensions/takes_screenshot.rb", "lib/selenium/webdriver/firefox/binary.rb", "lib/selenium/webdriver/firefox/bridge.rb", "lib/selenium/webdriver/firefox/extension.rb", "lib/selenium/webdriver/firefox/launcher.rb", "lib/selenium/webdriver/firefox/profile.rb", "lib/selenium/webdriver/firefox/profiles_ini.rb", "lib/selenium/webdriver/firefox/socket_lock.rb", "lib/selenium/webdriver/firefox/util.rb", "lib/selenium/webdriver/firefox/extension/webdriver.xpi", "lib/selenium/webdriver/firefox/native/linux/amd64/x_ignore_nofocus.so", "lib/selenium/webdriver/firefox/native/linux/x86/x_ignore_nofocus.so", "lib/selenium/webdriver/ie/bridge.rb", "lib/selenium/webdriver/ie/lib.rb", "lib/selenium/webdriver/ie/util.rb", "lib/selenium/webdriver/ie/native/win32/InternetExplorerDriver.dll", "lib/selenium/webdriver/ie/native/x64/InternetExplorerDriver.dll", "lib/selenium/webdriver/iphone/bridge.rb", "lib/selenium/webdriver/remote/bridge.rb", "lib/selenium/webdriver/remote/capabilities.rb", "lib/selenium/webdriver/remote/commands.rb", "lib/selenium/webdriver/remote/response.rb", "lib/selenium/webdriver/remote/server_error.rb", "lib/selenium/webdriver/remote/http/common.rb", "lib/selenium/webdriver/remote/http/curb.rb", "lib/selenium/webdriver/remote/http/default.rb", "CHANGES", "README"]
  s.homepage = %q{http://selenium.googlecode.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{The next generation developer focused tool for automated testing of webapps}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rubyzip>, [">= 0"])
      s.add_runtime_dependency(%q<childprocess>, ["= 0.1.4"])
      s.add_runtime_dependency(%q<ffi>, ["~> 0.6.3"])
      s.add_development_dependency(%q<rspec>, ["= 1.3.0"])
      s.add_development_dependency(%q<rack>, ["~> 1.0"])
      s.add_development_dependency(%q<ci_reporter>, ["~> 1.6.2"])
    else
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rubyzip>, [">= 0"])
      s.add_dependency(%q<childprocess>, ["= 0.1.4"])
      s.add_dependency(%q<ffi>, ["~> 0.6.3"])
      s.add_dependency(%q<rspec>, ["= 1.3.0"])
      s.add_dependency(%q<rack>, ["~> 1.0"])
      s.add_dependency(%q<ci_reporter>, ["~> 1.6.2"])
    end
  else
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rubyzip>, [">= 0"])
    s.add_dependency(%q<childprocess>, ["= 0.1.4"])
    s.add_dependency(%q<ffi>, ["~> 0.6.3"])
    s.add_dependency(%q<rspec>, ["= 1.3.0"])
    s.add_dependency(%q<rack>, ["~> 1.0"])
    s.add_dependency(%q<ci_reporter>, ["~> 1.6.2"])
  end
end
