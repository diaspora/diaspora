require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Ohai::System, "plugin etc" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
  end

  PasswdEntry = Struct.new(:name, :uid, :gid, :dir, :shell, :gecos)
  GroupEntry = Struct.new(:name, :gid, :mem)

  it "should include a list of all users" do
    Etc.should_receive(:passwd).and_yield(PasswdEntry.new("root", 1, 1, '/root', '/bin/zsh', 'BOFH')).
      and_yield(PasswdEntry.new('www', 800, 800, '/var/www', '/bin/false', 'Serving the web since 1970'))
    @ohai._require_plugin("passwd")
    @ohai[:etc][:passwd]['root'].should == Mash.new(:shell => '/bin/zsh', :gecos => 'BOFH', :gid => 1, :uid => 1, :dir => '/root')
    @ohai[:etc][:passwd]['www'].should == Mash.new(:shell => '/bin/false', :gecos => 'Serving the web since 1970', :gid => 800, :uid => 800, :dir => '/var/www')
  end
  
  it "should set the current user" do
    Etc.should_receive(:getlogin).and_return('chef')
    @ohai._require_plugin("passwd")
    @ohai[:current_user].should == 'chef'
  end
  
  it "should set the available groups" do
    Etc.should_receive(:group).and_yield(GroupEntry.new("admin", 100, ['root', 'chef'])).and_yield(GroupEntry.new('www', 800, ['www', 'deploy']))
    @ohai._require_plugin("passwd")
    @ohai[:etc][:group]['admin'].should == Mash.new(:gid => 100, :members => ['root', 'chef'])
    @ohai[:etc][:group]['www'].should == Mash.new(:gid => 800, :members => ['www', 'deploy'])
  end
end