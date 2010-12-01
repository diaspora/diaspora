#
# Author:: Cary Penniman (<cary@rightscale.com>)
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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper.rb')

describe Ohai::System, "plugin cloud" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
  end

  describe "no cloud" do
    it "should NOT populate the cloud data" do
      @ohai[:ec2] = nil
      @ohai[:rackspace] = nil
      @ohai._require_plugin("cloud")
      @ohai[:cloud].should be_nil
    end
  end
  
  describe "with EC2" do
    before(:each) do
      @ohai[:ec2] = Mash.new()
    end  
    
    it "should populate cloud public ip" do
      @ohai[:ec2]['public_ipv4'] = "174.129.150.8"
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:public_ips][0].should == @ohai[:ec2]['public_ipv4']
    end

    it "should populate cloud private ip" do
      @ohai[:ec2]['local_ipv4'] = "10.252.42.149"
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:private_ips][0].should == @ohai[:ec2]['local_ipv4']
    end
    
    it "should populate cloud provider" do
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:provider].should == "ec2"
    end
  end
  
  describe "with rackspace" do
    before(:each) do
      @ohai[:rackspace] = Mash.new()
    end  
    
    it "should populate cloud public ip" do
      @ohai[:rackspace]['public_ip'] = "174.129.150.8"
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:public_ips][0].should == @ohai[:rackspace][:public_ip]
    end
        
    it "should populate cloud private ip" do
      @ohai[:rackspace]['private_ip'] = "10.252.42.149"
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:private_ips][0].should == @ohai[:rackspace][:private_ip]
    end
    
     it "should populate first cloud public ip" do
      @ohai[:rackspace]['public_ip'] = "174.129.150.8"
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:public_ips].first.should == @ohai[:rackspace][:public_ip]
    end
        
    it "should populate cloud provider" do
      @ohai._require_plugin("cloud")
      @ohai[:cloud][:provider].should == "rackspace"
    end
  end
  
end
