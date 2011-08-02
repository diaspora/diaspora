module Jasmine
  class Config
    require 'yaml'
    require 'erb'

    def browser
      ENV["JASMINE_BROWSER"] || 'firefox'
    end

    def jasmine_host
      ENV["JASMINE_HOST"] || 'http://localhost'
    end

    def jasmine_port
      ENV["JASMINE_PORT"] || Jasmine::find_unused_port
    end

    def start_server(port = 8888)
      server = Rack::Server.new(:Port => port, :AccessLog => [])
      server.instance_variable_set(:@app, Jasmine.app(self)) # workaround for Rack bug, when Rack > 1.2.1 is released Rack::Server.start(:app => Jasmine.app(self)) will work
      server.start
    end

    def start
      start_jasmine_server
      @client = Jasmine::SeleniumDriver.new(browser, "#{jasmine_host}:#{@jasmine_server_port}/")
      @client.connect
    end

    def stop
      @client.disconnect
    end

    def start_jasmine_server
      @jasmine_server_port = jasmine_port
      Thread.new do
        start_server(@jasmine_server_port)
      end
      Jasmine::wait_for_listener(@jasmine_server_port, "jasmine server")
      puts "jasmine server started."
    end

    def windows?
      require 'rbconfig'
      ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    end

    def run
      begin
        start
        puts "servers are listening on their ports -- running the test script..."
        tests_passed = @client.run
      ensure
        stop
      end
      return tests_passed
    end

    def eval_js(script)
      @client.eval_js(script)
    end

    def json_generate(obj)
      @client.json_generate(obj)
    end

    def match_files(dir, patterns)
      dir = File.expand_path(dir)
      negative, positive = patterns.partition {|pattern| /^!/ =~ pattern}
      chosen, negated = [positive, negative].collect do |patterns|
        patterns.collect do |pattern|
          matches = Dir.glob(File.join(dir, pattern.gsub(/^!/,'')))
          matches.collect {|f| f.sub("#{dir}/", "")}.sort
        end.flatten.uniq
      end
      chosen - negated
    end

    def simple_config
      config = File.exist?(simple_config_file) ? YAML::load(ERB.new(File.read(simple_config_file)).result(binding)) : false
      config || {}
    end


    def spec_path
      "/__spec__"
    end

    def root_path
      "/__root__"
    end

    def js_files(spec_filter = nil)
      spec_files_to_include = spec_filter.nil? ? spec_files : match_files(spec_dir, [spec_filter])
      src_files.collect {|f| "/" + f } + helpers.collect {|f| File.join(spec_path, f) } + spec_files_to_include.collect {|f| File.join(spec_path, f) }
    end

    def css_files
      stylesheets.collect {|f| "/" + f }
    end

    def spec_files_full_paths
      spec_files.collect {|spec_file| File.join(spec_dir, spec_file) }
    end

    def project_root
      Dir.pwd
    end

    def simple_config_file
      File.join(project_root, 'spec/javascripts/support/jasmine.yml')
    end

    def src_dir
      if simple_config['src_dir']
        File.join(project_root, simple_config['src_dir'])
      else
        project_root
      end
    end

    def spec_dir
      if simple_config['spec_dir']
        File.join(project_root, simple_config['spec_dir'])
      else
        File.join(project_root, 'spec/javascripts')
      end
    end

    def helpers
      if simple_config['helpers']
        match_files(spec_dir, simple_config['helpers'])
      else
        match_files(spec_dir, ["helpers/**/*.js"])
      end
    end

    def src_files
      if simple_config['src_files']
        match_files(src_dir, simple_config['src_files'])
      else
        []
      end
    end

    def spec_files
      if simple_config['spec_files']
        match_files(spec_dir, simple_config['spec_files'])
      else
        match_files(spec_dir, ["**/*[sS]pec.js"])
      end
    end

    def stylesheets
      if simple_config['stylesheets']
        match_files(src_dir, simple_config['stylesheets'])
      else
        []
      end
    end
  end
end