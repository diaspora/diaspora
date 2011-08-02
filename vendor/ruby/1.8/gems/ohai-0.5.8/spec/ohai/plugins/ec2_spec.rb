#
# Author:: Tim Dysinger (<tim@dysinger.net>)
# Author:: Christopher Brown (cb@opscode.com)
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
require 'open-uri'

describe Ohai::System, "plugin ec2" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:network] = {:interfaces => {:eth0 => {} } }
  end

  describe "!ec2", :shared => true do
    it "should NOT attempt to fetch the ec2 metadata" do
      OpenURI.should_not_receive(:open)
      @ohai._require_plugin("ec2")
    end
  end

  describe "ec2", :shared => true do
    before(:each) do
      OpenURI.stub!(:open_uri).
        with("http://169.254.169.254/2008-02-01/meta-data/").
        and_return(mock(IO, :read => "instance_type\nami_id\nsecurity-groups"))
      OpenURI.stub!(:open_uri).
        with("http://169.254.169.254/2008-02-01/meta-data/instance_type").
        and_return(mock(IO, :read => "c1.medium"))
      OpenURI.stub!(:open_uri).
        with("http://169.254.169.254/2008-02-01/meta-data/ami_id").
        and_return(mock(IO, :read => "ami-5d2dc934"))
      OpenURI.stub!(:open_uri).
        with("http://169.254.169.254/2008-02-01/meta-data/security-groups").
        and_return(mock(IO, :read => "group1\ngroup2"))
      OpenURI.stub!(:open_uri).
        with("http://169.254.169.254/2008-02-01/user-data/").
        and_return(mock(IO, :gets => "By the pricking of my thumb..."))
    end

    it "should recursively fetch all the ec2 metadata" do
      IO.stub!(:select).and_return([[],[1],[]])
      t = mock("connection")
      t.stub!(:connect_nonblock).and_raise(Errno::EINPROGRESS)
      Socket.stub!(:new).and_return(t)
      @ohai._require_plugin("ec2")
      @ohai[:ec2].should_not be_nil
      @ohai[:ec2]['instance_type'].should == "c1.medium"
      @ohai[:ec2]['ami_id'].should == "ami-5d2dc934"
      @ohai[:ec2]['security_groups'].should eql ['group1', 'group2']
    end
  end

  describe "with ec2 mac and metadata address connected" do
    it_should_behave_like "ec2"

    before(:each) do
      IO.stub!(:select).and_return([[],[1],[]])
      @ohai[:network][:interfaces][:eth0][:arp] = {"169.254.1.0"=>"fe:ff:ff:ff:ff:ff"}
    end
  end

  describe "without ec2 mac and metadata address connected" do
    it_should_behave_like "!ec2"
    
    before(:each) do
      @ohai[:network][:interfaces][:eth0][:arp] = {"169.254.1.0"=>"00:50:56:c0:00:08"}
    end
  end
end
