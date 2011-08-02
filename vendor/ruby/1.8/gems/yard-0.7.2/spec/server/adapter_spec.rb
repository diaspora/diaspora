require File.dirname(__FILE__) + '/spec_helper'

describe YARD::Server::Adapter do
  after(:all) { Server::Adapter.shutdown }

  describe '#add_library' do
    it "should add a library" do
      lib = LibraryVersion.new('yard')
      a = Adapter.new({})
      a.libraries.should be_empty
      a.add_library(lib)
      a.libraries['yard'].should == [lib]
    end
  end
  
  describe '#start' do
    it "should not implement #start" do
      lambda { Adapter.new({}).start }.should raise_error(NotImplementedError)
    end
  end
  
  describe '.setup' do
    it 'should add template paths and helpers' do
      Adapter.setup
      Templates::Template.extra_includes.should include(DocServerHelper)
      Templates::Engine.template_paths.should include(YARD::ROOT + '/yard/server/templates')
    end
  end
  
  describe '.shutdown' do
    it 'should cleanup template paths and helpers' do
      Adapter.setup
      Adapter.shutdown
      Templates::Template.extra_includes.should_not include(DocServerHelper)
      Templates::Engine.template_paths.should_not include(YARD::ROOT + '/yard/server/templates')
    end
  end
end