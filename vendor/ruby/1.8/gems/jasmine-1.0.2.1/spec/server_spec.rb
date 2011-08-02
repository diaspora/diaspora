require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
require 'rack/test'

describe "Jasmine.app" do
  include Rack::Test::Methods

  def app
    config = Jasmine::Config.new
    config.stub!(:project_root).and_return(Jasmine.root)
    config.stub!(:spec_dir).and_return(File.join(Jasmine.root, "spec"))
    config.stub!(:src_dir).and_return(File.join(Jasmine.root, "src"))
    config.stub!(:src_files).and_return(["file1.js"])
    config.stub!(:spec_files).and_return(["file2.js"])
    Jasmine.app(config)
  end

  it "should serve static files from spec dir under __spec__" do
    get "/__spec__/suites/EnvSpec.js"
    last_response.status.should == 200
    last_response.content_type.should == "application/javascript"
    last_response.body.should == File.read(File.join(Jasmine.root, "spec/suites/EnvSpec.js"))
    end

  it "should serve static files from root dir under __root__" do
    get "/__root__/src/base.js"
    last_response.status.should == 200
    last_response.content_type.should == "application/javascript"
    last_response.body.should == File.read(File.join(Jasmine.root, "src/base.js"))
  end

  it "should serve static files from src dir under /" do
    get "/base.js"
    last_response.status.should == 200
    last_response.content_type.should == "application/javascript"
    last_response.body.should == File.read(File.join(Jasmine.root, "src/base.js"))
  end

  it "should serve Jasmine static files under /__JASMINE_ROOT__/" do
    get "/__JASMINE_ROOT__/lib/jasmine.css"
    last_response.status.should == 200
    last_response.content_type.should == "text/css"
    last_response.body.should == File.read(File.join(Jasmine.root, "lib/jasmine.css"))
  end

  it "should serve focused suites when prefixing spec files with /__suite__/" do
    Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
    get "/__suite__/file2.js"
    last_response.status.should == 200
    last_response.content_type.should == "text/html"
    last_response.body.should include("\"/__spec__/file2.js")
  end

  it "should redirect /run.html to /" do
    get "/run.html"
    last_response.status.should == 302
    last_response.location.should == "/"
  end

  it "should 404 non-existent files" do
    get "/some-non-existent-file"
    last_response.should be_not_found
  end

  describe "/ page" do
    it "should load each js file in order" do
      get "/"
      last_response.status.should == 200
      last_response.body.should include("\"/file1.js")
      last_response.body.should include("\"/__spec__/file2.js")
      last_response.body.should satisfy {|s| s.index("/file1.js") < s.index("/__spec__/file2.js") }
    end

    it "should return an empty 200 for HEAD requests to /" do
      head "/"
      last_response.status.should == 200
      last_response.headers.should == { 'Content-Type' => 'text/html' }
      last_response.body.should == ''
    end
  end
end
