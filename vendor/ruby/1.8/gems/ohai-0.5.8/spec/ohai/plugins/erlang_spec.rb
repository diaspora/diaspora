#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

describe Ohai::System, "plugin erlang" do

  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:languages] = Mash.new    
    @ohai.stub!(:require_plugin).and_return(true)
    @status = 0
    @stdin = ""
    @stderr = "Erlang (ASYNC_THREADS,SMP,HIPE) (BEAM) emulator version 5.6.2\n"
    @ohai.stub!(:run_command).with({:no_status_check => true, :command => "erl +V"}).and_return([@status, @stdout, @stderr])
  end
  
  it "should get the erlang version from erl +V" do
    @ohai.should_receive(:run_command).with({:no_status_check => true, :command => "erl +V"}).and_return([0, "", "Erlang (ASYNC_THREADS,SMP,HIPE) (BEAM) emulator version 5.6.2\n"])
    @ohai._require_plugin("erlang")
  end

  it "should set languages[:erlang][:version]" do
    @ohai._require_plugin("erlang")
    @ohai.languages[:erlang][:version].should eql("5.6.2")
  end
  
  it "should set languages[:erlang][:options]" do
    @ohai._require_plugin("erlang")
    @ohai.languages[:erlang][:options].should eql(["ASYNC_THREADS", "SMP", "HIPE"])
  end
  
  it "should set languages[:erlang][:emulator]" do
    @ohai._require_plugin("erlang")
    @ohai.languages[:erlang][:emulator].should eql("BEAM")
  end
  
  it "should not set the languages[:erlang] tree up if erlang command fails" do
    @status = 1
    @stdin = ""
    @stderr = "Erlang (ASYNC_THREADS,SMP,HIPE) (BEAM) emulator version 5.6.2\n"
    @ohai.stub!(:run_command).with({:no_status_check => true, :command => "erl +V"}).and_return([@status, @stdout, @stderr])
    @ohai._require_plugin("erlang")
    @ohai.languages.should_not have_key(:erlang)
  end
  
end
