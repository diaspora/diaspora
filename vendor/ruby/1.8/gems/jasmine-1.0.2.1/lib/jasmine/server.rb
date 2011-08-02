require 'rack'

module Jasmine
  class RunAdapter
    def initialize(config)
      @config = config
      @jasmine_files = [
        "/__JASMINE_ROOT__/lib/jasmine.js",
        "/__JASMINE_ROOT__/lib/jasmine-html.js",
        "/__JASMINE_ROOT__/lib/json2.js",
      ]
      @jasmine_stylesheets = ["/__JASMINE_ROOT__/lib/jasmine.css"]
    end

    def call(env)
      return not_found if env["PATH_INFO"] != "/"
      run
    end

    def not_found
      body = "File not found: #{@path_info}\n"
      [404, {"Content-Type" => "text/plain",
             "Content-Length" => body.size.to_s,
             "X-Cascade" => "pass"},
       [body]]
    end

    #noinspection RubyUnusedLocalVariable
    def run(focused_suite = nil)
      jasmine_files = @jasmine_files
      css_files = @jasmine_stylesheets + (@config.css_files || [])
      js_files = @config.js_files(focused_suite)
      body = ERB.new(File.read(File.join(File.dirname(__FILE__), "run.html.erb"))).result(binding)
      [
        200,
        { 'Content-Type' => 'text/html' },
        [body]
      ]
    end
  end

  class Redirect
    def initialize(url)
      @url = url
    end

    def call(env)
      [
        302,
        { 'Location' => @url },
        []
      ]
    end
  end

  class JsAlert
    def call(env)
      [
        200,
        { 'Content-Type' => 'application/javascript' },
        ["document.write('<p>Couldn\\'t load #{env["PATH_INFO"]}!</p>');"]
      ]
    end
  end

  class FocusedSuite
    def initialize(config)
      @config = config
    end

    def call(env)
      run_adapter = Jasmine::RunAdapter.new(@config)
      run_adapter.run(env["PATH_INFO"])
    end
  end

  def self.app(config)
    Rack::Builder.app do
      use Rack::Head

      map('/run.html')         { run Jasmine::Redirect.new('/') }
      map('/__suite__')        { run Jasmine::FocusedSuite.new(config) }

      map('/__JASMINE_ROOT__') { run Rack::File.new(Jasmine.root) }
      map(config.spec_path)    { run Rack::File.new(config.spec_dir) }
      map(config.root_path)    { run Rack::File.new(config.project_root) }

      map('/') do
        run Rack::Cascade.new([
          Rack::URLMap.new('/' => Rack::File.new(config.src_dir)),
          Jasmine::RunAdapter.new(config)
        ])
      end
    end
  end
end
