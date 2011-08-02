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

describe Ohai::System, "plugin rackspace" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:network] = {:interfaces => {:eth0 => {"addresses"=> {
          "1.2.3.4"=> {
            "broadcast"=> "67.23.20.255",
            "netmask"=> "255.255.255.0",
            "family"=> "inet"
          },
          "fe80::4240:95ff:fe47:6eed"=> {
            "scope"=> "Link",
            "prefixlen"=> "64",
            "family"=> "inet6"
          },
          "40:40:95:47:6E:ED"=> {
            "family"=> "lladdr"
          }
        }}
      }
    }
        
    @ohai[:network][:interfaces][:eth1] = {:addresses => {  
         "fe80::4240:f5ff:feab:2836" => {
            "scope"=> "Link",
            "prefixlen"=> "64",
            "family"=> "inet6"
          },
          "5.6.7.8"=> {
            "broadcast"=> "10.176.191.255",
            "netmask"=> "255.255.224.0",
            "family"=> "inet"
          },
          "40:40:F5:AB:28:36" => {
            "family"=> "lladdr"
          }
        }}
  end

  describe "!rackspace", :shared => true  do
    it "should NOT create rackspace" do
      @ohai._require_plugin("rackspace")
      @ohai[:rackspace].should be_nil
    end
  end
  
  describe "rackspace", :shared => true do
    
    it "should create rackspace" do
      @ohai._require_plugin("rackspace")
      @ohai[:rackspace].should_not be_nil
    end
    
    it "should have all required attributes" do
      @ohai._require_plugin("rackspace")
      @ohai[:rackspace][:public_ip].should_not be_nil
      @ohai[:rackspace][:private_ip].should_not be_nil
    end

    it "should have correct values for all attributes" do
      @ohai._require_plugin("rackspace")
      @ohai[:rackspace][:public_ip].should == "1.2.3.4"
      @ohai[:rackspace][:private_ip].should == "5.6.7.8"
    end
    
  end

    describe "with rackspace mac and hostname" do
      it_should_behave_like "rackspace"
  
      before(:each) do
        IO.stub!(:select).and_return([[],[1],[]])
        @ohai[:hostname] = "slice74976"
        @ohai[:network][:interfaces][:eth0][:arp] = {"67.23.20.1" => "00:00:0c:07:ac:01"} 
      end
    end
  
    describe "without rackspace mac" do
      it_should_behave_like "!rackspace"
      
      before(:each) do
        @ohai[:hostname] = "slice74976"
        @ohai[:network][:interfaces][:eth0][:arp] = {"169.254.1.0"=>"fe:ff:ff:ff:ff:ff"}
      end
    end

    describe "without rackspace hostname" do
      it_should_behave_like "rackspace"
      
      before(:each) do
        @ohai[:hostname] = "bubba"
        @ohai[:network][:interfaces][:eth0][:arp] = {"67.23.20.1" => "00:00:0c:07:ac:01"} 
      end
    end

end
