# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack}
  s.version = "1.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian Neukirchen"]
  s.date = %q{2011-05-23}
  s.default_executable = %q{rackup}
  s.description = %q{Rack provides minimal, modular and adaptable interface for developing
web applications in Ruby.  By wrapping HTTP requests and responses in
the simplest way possible, it unifies and distills the API for web
servers, web frameworks, and software in between (the so-called
middleware) into a single method call.

Also see http://rack.rubyforge.org.
}
  s.email = %q{chneukirchen@gmail.com}
  s.executables = ["rackup"]
  s.extra_rdoc_files = ["README", "SPEC", "KNOWN-ISSUES"]
  s.files = ["bin/rackup", "contrib/rack_logo.svg", "example/lobster.ru", "example/protectedlobster.rb", "example/protectedlobster.ru", "lib/rack/auth/abstract/handler.rb", "lib/rack/auth/abstract/request.rb", "lib/rack/auth/basic.rb", "lib/rack/auth/digest/md5.rb", "lib/rack/auth/digest/nonce.rb", "lib/rack/auth/digest/params.rb", "lib/rack/auth/digest/request.rb", "lib/rack/builder.rb", "lib/rack/cascade.rb", "lib/rack/chunked.rb", "lib/rack/commonlogger.rb", "lib/rack/conditionalget.rb", "lib/rack/config.rb", "lib/rack/content_length.rb", "lib/rack/content_type.rb", "lib/rack/deflater.rb", "lib/rack/directory.rb", "lib/rack/etag.rb", "lib/rack/file.rb", "lib/rack/handler/cgi.rb", "lib/rack/handler/evented_mongrel.rb", "lib/rack/handler/fastcgi.rb", "lib/rack/handler/lsws.rb", "lib/rack/handler/mongrel.rb", "lib/rack/handler/scgi.rb", "lib/rack/handler/swiftiplied_mongrel.rb", "lib/rack/handler/thin.rb", "lib/rack/handler/webrick.rb", "lib/rack/handler.rb", "lib/rack/head.rb", "lib/rack/lint.rb", "lib/rack/lobster.rb", "lib/rack/lock.rb", "lib/rack/logger.rb", "lib/rack/methodoverride.rb", "lib/rack/mime.rb", "lib/rack/mock.rb", "lib/rack/nulllogger.rb", "lib/rack/recursive.rb", "lib/rack/reloader.rb", "lib/rack/request.rb", "lib/rack/response.rb", "lib/rack/rewindable_input.rb", "lib/rack/runtime.rb", "lib/rack/sendfile.rb", "lib/rack/server.rb", "lib/rack/session/abstract/id.rb", "lib/rack/session/cookie.rb", "lib/rack/session/memcache.rb", "lib/rack/session/pool.rb", "lib/rack/showexceptions.rb", "lib/rack/showstatus.rb", "lib/rack/static.rb", "lib/rack/urlmap.rb", "lib/rack/utils.rb", "lib/rack.rb", "test/cgi/lighttpd.conf", "test/cgi/rackup_stub.rb", "test/cgi/sample_rackup.ru", "test/cgi/test", "test/cgi/test.fcgi", "test/cgi/test.ru", "test/gemloader.rb", "test/multipart/bad_robots", "test/multipart/binary", "test/multipart/empty", "test/multipart/fail_16384_nofile", "test/multipart/file1.txt", "test/multipart/filename_and_modification_param", "test/multipart/filename_with_escaped_quotes", "test/multipart/filename_with_escaped_quotes_and_modification_param", "test/multipart/filename_with_percent_escaped_quotes", "test/multipart/filename_with_unescaped_quotes", "test/multipart/ie", "test/multipart/nested", "test/multipart/none", "test/multipart/semicolon", "test/multipart/text", "test/rackup/config.ru", "test/spec_auth_basic.rb", "test/spec_auth_digest.rb", "test/spec_builder.rb", "test/spec_cascade.rb", "test/spec_cgi.rb", "test/spec_chunked.rb", "test/spec_commonlogger.rb", "test/spec_conditionalget.rb", "test/spec_config.rb", "test/spec_content_length.rb", "test/spec_content_type.rb", "test/spec_deflater.rb", "test/spec_directory.rb", "test/spec_etag.rb", "test/spec_fastcgi.rb", "test/spec_file.rb", "test/spec_handler.rb", "test/spec_head.rb", "test/spec_lint.rb", "test/spec_lobster.rb", "test/spec_lock.rb", "test/spec_logger.rb", "test/spec_methodoverride.rb", "test/spec_mock.rb", "test/spec_mongrel.rb", "test/spec_nulllogger.rb", "test/spec_recursive.rb", "test/spec_request.rb", "test/spec_response.rb", "test/spec_rewindable_input.rb", "test/spec_runtime.rb", "test/spec_sendfile.rb", "test/spec_session_cookie.rb", "test/spec_session_memcache.rb", "test/spec_session_pool.rb", "test/spec_showexceptions.rb", "test/spec_showstatus.rb", "test/spec_static.rb", "test/spec_thin.rb", "test/spec_urlmap.rb", "test/spec_utils.rb", "test/spec_webrick.rb", "test/testrequest.rb", "test/unregistered_handler/rack/handler/unregistered.rb", "test/unregistered_handler/rack/handler/unregistered_long_one.rb", "COPYING", "KNOWN-ISSUES", "rack.gemspec", "Rakefile", "README", "SPEC"]
  s.homepage = %q{http://rack.rubyforge.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{a modular Ruby webserver interface}
  s.test_files = ["test/spec_auth_basic.rb", "test/spec_auth_digest.rb", "test/spec_builder.rb", "test/spec_cascade.rb", "test/spec_cgi.rb", "test/spec_chunked.rb", "test/spec_commonlogger.rb", "test/spec_conditionalget.rb", "test/spec_config.rb", "test/spec_content_length.rb", "test/spec_content_type.rb", "test/spec_deflater.rb", "test/spec_directory.rb", "test/spec_etag.rb", "test/spec_fastcgi.rb", "test/spec_file.rb", "test/spec_handler.rb", "test/spec_head.rb", "test/spec_lint.rb", "test/spec_lobster.rb", "test/spec_lock.rb", "test/spec_logger.rb", "test/spec_methodoverride.rb", "test/spec_mock.rb", "test/spec_mongrel.rb", "test/spec_nulllogger.rb", "test/spec_recursive.rb", "test/spec_request.rb", "test/spec_response.rb", "test/spec_rewindable_input.rb", "test/spec_runtime.rb", "test/spec_sendfile.rb", "test/spec_session_cookie.rb", "test/spec_session_memcache.rb", "test/spec_session_pool.rb", "test/spec_showexceptions.rb", "test/spec_showstatus.rb", "test/spec_static.rb", "test/spec_thin.rb", "test/spec_urlmap.rb", "test/spec_utils.rb", "test/spec_webrick.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<fcgi>, [">= 0"])
      s.add_development_dependency(%q<memcache-client>, [">= 0"])
      s.add_development_dependency(%q<mongrel>, [">= 0"])
      s.add_development_dependency(%q<thin>, [">= 0"])
    else
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<fcgi>, [">= 0"])
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<mongrel>, [">= 0"])
      s.add_dependency(%q<thin>, [">= 0"])
    end
  else
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<fcgi>, [">= 0"])
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<mongrel>, [">= 0"])
    s.add_dependency(%q<thin>, [">= 0"])
  end
end
