#
# Author:: Joshua Timberman(<joshua@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Ohai::System, "plugin perl" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:languages] = Mash.new
    @ohai.stub!(:require_plugin).and_return(true)
    @pid = mock("PID", :null_object => true)
    @stderr = mock("STDERR", :null_object => true)
    @stdout = mock("STDOUT", :null_object => true)
    @stdout.stub!(:each_line).and_yield("version='5.8.8';").
      and_yield("archname='darwin-thread-multi-2level';")
    @stdin = mock("STDIN", :null_object => true)
    @status = 0
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"perl -V:version -V:archname"}).and_return([
      @status,
      @stdout,
      @stderr
    ])
  end
  
  it "should run perl -V:version -V:archname" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"perl -V:version -V:archname"}).and_return(true)
    @ohai._require_plugin("perl")
  end
  
  it "should iterate over each line of perl command's stdout" do
    @stdout.should_receive(:each_line).and_return(true)
    @ohai._require_plugin("perl")
  end

  it "should set languages[:perl][:version]" do
    @ohai._require_plugin("perl")
    @ohai.languages[:perl][:version].should eql("5.8.8")
  end  
    
  it "should set languages[:perl][:archname]" do
    @ohai._require_plugin("perl")
    @ohai.languages[:perl][:archname].should eql("darwin-thread-multi-2level")
  end
  
  it "should set languages[:perl] if perl command succeeds" do
    @status = 0
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"perl -V:version -V:archname"}).and_return([
      @status,
      @stdout,
      @stderr
    ])
    @ohai._require_plugin("perl")
    @ohai.languages.should have_key(:perl)
  end
  
  it "should not set languages[:perl] if perl command fails" do
     @status = 1
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"perl -V:version -V:archname"}).and_return([
      @status,
      @stdout,
      @stderr
     ])
     @ohai._require_plugin("perl")
     @ohai.languages.should_not have_key(:perl)
  end
end
