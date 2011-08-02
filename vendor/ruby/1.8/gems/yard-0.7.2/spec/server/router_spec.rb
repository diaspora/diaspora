require File.dirname(__FILE__) + '/spec_helper'

class MyRouterSpecRouter < Router
  def docs_prefix; 'mydocs/foo' end
  def list_prefix; 'mylist/foo' end
  def search_prefix; 'mysearch/foo' end
  
  def check_static_cache; nil end
end

describe YARD::Server::Router do
  before do
    @adapter = mock_adapter
    @projects = @adapter.libraries['project']
  end

  describe '#parse_library_from_path' do
    def parse(*args)
      MyRouterSpecRouter.new(@adapter).parse_library_from_path(args.flatten)
    end
    
    it "should parse library and version name out of path" do
      parse('project', '1.0.0').should == [@projects[0], []]
    end
    
    it "should parse library and use latest version if version is not supplied" do
      parse('project').should == [@projects[1], []]
    end

    it "should parse library and use latest version if next component is not a version" do
      parse('project', 'notaversion').should == [@projects[1], ['notaversion']]
    end
    
    it "should return nil library if no library is found" do
      parse('notproject').should == [nil, ['notproject']]
    end
    
    it "should not parse library or version if single_library == true" do
      @adapter.stub!(:options).and_return(:single_library => true)
      parse('notproject').should == [@projects[0], ['notproject']]
    end
  end
  
  describe '#route' do
    def route_to(route, command, *args)
      req = mock_request(route)
      router = MyRouterSpecRouter.new(@adapter)
      command.should_receive(:new).and_return do |*args|
        @command = command.allocate
        @command.send(:initialize, *args)
        class << @command; def call(req); self end end
        @command
      end
      router.call(req)
    end
    
    it "should route /docs/OBJECT to object if single_library = true" do
      @adapter.stub!(:options).and_return(:single_library => true)
      route_to('/mydocs/foo/FOO', DisplayObjectCommand)
    end
    
    it "should route /docs" do
      route_to('/mydocs/foo', LibraryIndexCommand)
    end
    
    it "should route /docs as index for library if single_library == true" do
      @adapter.stub!(:options).and_return(:single_library => true)
      route_to('/mydocs/foo/', DisplayObjectCommand)
    end
    
    it "should route /docs/name/version" do
      route_to('/mydocs/foo/project/1.0.0', DisplayObjectCommand)
      @command.library.should == @projects[0]
    end
    
    it "should route /docs/name/ to latest version of library" do
      route_to('/mydocs/foo/project', DisplayObjectCommand)
      @command.library.should == @projects[1]
    end
    
    it "should route /list/name/version/class" do
      route_to('/mylist/foo/project/1.0.0/class', ListClassesCommand)
      @command.library.should == @projects[0]
    end

    it "should route /list/name/version/methods" do
      route_to('/mylist/foo/project/1.0.0/methods', ListMethodsCommand)
      @command.library.should == @projects[0]
    end

    it "should route /list/name/version/files" do
      route_to('/mylist/foo/project/1.0.0/files', ListFilesCommand)
      @command.library.should == @projects[0]
    end
    
    it "should route /list/name to latest version of library" do
      route_to('/mylist/foo/project/class', ListClassesCommand)
      @command.library.should == @projects[1]
    end
    
    it "should route /search/name/version" do
      route_to('/mysearch/foo/project/1.0.0', SearchCommand)
      @command.library.should == @projects[0]
    end
    
    it "should route /search/name to latest version of library" do
      route_to('/mysearch/foo/project', SearchCommand)
      @command.library.should == @projects[1]
    end

    it "should search static files for non-existent library" do
      route_to('/mydocs/foo/notproject', StaticFileCommand)
    end
  end
end