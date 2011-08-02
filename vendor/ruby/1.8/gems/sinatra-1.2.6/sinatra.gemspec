Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'sinatra'
  s.version = '1.2.6'
  s.date = '2011-05-01'

  s.description = "Classy web-development dressed in a DSL"
  s.summary     = "Classy web-development dressed in a DSL"

  s.authors = ["Blake Mizerany", "Ryan Tomayko", "Simon Rozet", "Konstantin Haase"]
  s.email = "sinatrarb@googlegroups.com"

  # = MANIFEST =
  s.files = %w[
    AUTHORS
    CHANGES
    Gemfile
    LICENSE
    README.de.rdoc
    README.es.rdoc
    README.fr.rdoc
    README.hu.rdoc
    README.jp.rdoc
    README.pt-br.rdoc
    README.pt-pt.rdoc
    README.rdoc
    README.ru.rdoc
    README.zh.rdoc
    Rakefile
    lib/sinatra.rb
    lib/sinatra/base.rb
    lib/sinatra/images/404.png
    lib/sinatra/images/500.png
    lib/sinatra/main.rb
    lib/sinatra/showexceptions.rb
    sinatra.gemspec
    test/base_test.rb
    test/builder_test.rb
    test/coffee_test.rb
    test/contest.rb
    test/delegator_test.rb
    test/encoding_test.rb
    test/erb_test.rb
    test/erubis_test.rb
    test/extensions_test.rb
    test/filter_test.rb
    test/haml_test.rb
    test/hello.mab
    test/helper.rb
    test/helpers_test.rb
    test/less_test.rb
    test/liquid_test.rb
    test/mapped_error_test.rb
    test/markaby_test.rb
    test/markdown_test.rb
    test/middleware_test.rb
    test/nokogiri_test.rb
    test/public/favicon.ico
    test/radius_test.rb
    test/rdoc_test.rb
    test/request_test.rb
    test/response_test.rb
    test/result_test.rb
    test/route_added_hook_test.rb
    test/routing_test.rb
    test/sass_test.rb
    test/scss_test.rb
    test/server_test.rb
    test/settings_test.rb
    test/sinatra_test.rb
    test/slim_test.rb
    test/static_test.rb
    test/templates_test.rb
    test/textile_test.rb
    test/views/a/in_a.str
    test/views/ascii.erb
    test/views/b/in_b.str
    test/views/calc.html.erb
    test/views/error.builder
    test/views/error.erb
    test/views/error.erubis
    test/views/error.haml
    test/views/error.sass
    test/views/explicitly_nested.str
    test/views/foo/hello.test
    test/views/hello.builder
    test/views/hello.coffee
    test/views/hello.erb
    test/views/hello.erubis
    test/views/hello.haml
    test/views/hello.less
    test/views/hello.liquid
    test/views/hello.mab
    test/views/hello.md
    test/views/hello.nokogiri
    test/views/hello.radius
    test/views/hello.rdoc
    test/views/hello.sass
    test/views/hello.scss
    test/views/hello.slim
    test/views/hello.str
    test/views/hello.test
    test/views/hello.textile
    test/views/layout2.builder
    test/views/layout2.erb
    test/views/layout2.erubis
    test/views/layout2.haml
    test/views/layout2.liquid
    test/views/layout2.mab
    test/views/layout2.nokogiri
    test/views/layout2.radius
    test/views/layout2.slim
    test/views/layout2.str
    test/views/layout2.test
    test/views/nested.str
    test/views/utf8.erb
  ]
  # = MANIFEST =

  s.test_files = s.files.select {|path| path =~ /^test\/.*_test.rb/}

  s.extra_rdoc_files = %w[README.rdoc README.de.rdoc README.jp.rdoc README.fr.rdoc README.es.rdoc README.hu.rdoc README.zh.rdoc LICENSE]
  s.add_dependency 'rack', '~> 1.1'
  s.add_dependency 'tilt', '>= 1.2.2', '< 2.0'
  s.add_development_dependency 'shotgun', '~> 0.6'

  s.homepage = "http://sinatra.rubyforge.org"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Sinatra", "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  s.rubyforge_project = 'sinatra'
  s.rubygems_version = '1.1.1'
end
