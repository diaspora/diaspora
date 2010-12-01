#
# Author:: Thom May (<thom@clearairturbulence.org>)
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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')

describe Ohai::System, "Linux virtualization platform" do
  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:os] = "linux"
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai.extend(SimpleFromFile)

    # default to all requested Files not existing
    File.stub!(:exists?).with("/proc/xen/capabilities").and_return(false)
    File.stub!(:exists?).with("/proc/sys/xen/independent_wallclock").and_return(false)
    File.stub!(:exists?).with("/proc/modules").and_return(false)
    File.stub!(:exists?).with("/proc/cpuinfo").and_return(false)
    File.stub!(:exists?).with("/usr/sbin/dmidecode").and_return(false)
  end

  describe "when we are checking for xen" do
    it "should set xen host if /proc/xen/capabilities contains control_d" do
      File.should_receive(:exists?).with("/proc/xen/capabilities").and_return(true)
      File.stub!(:read).with("/proc/xen/capabilities").and_return("control_d")
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization][:emulator].should == "xen" 
      @ohai[:virtualization][:role].should == "host"
    end

    it "should set xen guest if /proc/sys/xen/independent_wallclock exists" do
      File.should_receive(:exists?).with("/proc/sys/xen/independent_wallclock").and_return(true)
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization][:emulator].should == "xen"
      @ohai[:virtualization][:role].should == "guest"
    end

    it "should not set virtualization if xen isn't there" do
      File.should_receive(:exists?).at_least(:once).and_return(false)
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization].should == {}
    end
  end

  describe "when we are checking for kvm" do
    it "should set kvm host if /proc/modules contains kvm" do
      File.should_receive(:exists?).with("/proc/modules").and_return(true)
      File.stub!(:read).with("/proc/modules").and_return("kvm 165872  1 kvm_intel")
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization][:emulator].should == "kvm"
      @ohai[:virtualization][:role].should == "host"
    end
    
    it "should set kvm guest if /proc/cpuinfo contains QEMU Virtual CPU" do
      File.should_receive(:exists?).with("/proc/cpuinfo").and_return(true)
      File.stub!(:read).with("/proc/cpuinfo").and_return("QEMU Virtual CPU")
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization][:emulator].should == "kvm"
      @ohai[:virtualization][:role].should == "guest"
    end

    it "should not set virtualization if kvm isn't there" do
      File.should_receive(:exists?).at_least(:once).and_return(false)
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization].should == {}
    end
  end

  describe "when we are parsing dmidecode" do
    before(:each) do
      File.should_receive(:exists?).with("/usr/sbin/dmidecode").and_return(true)
      @stdin = mock("STDIN", { :close => true })
      @pid = 10
      @stderr = mock("STDERR")
      @stdout = mock("STDOUT")
      @status = 0
    end

    it "should run dmidecode" do
      @ohai.should_receive(:popen4).with("dmidecode").and_return(true)
      @ohai._require_plugin("linux::virtualization")
    end

    it "should set virtualpc guest if dmidecode detects Microsoft Virtual Machine" do
      ms_vpc_dmidecode=<<-MSVPC
System Information
	Manufacturer: Microsoft Corporation
	Product Name: Virtual Machine
	Version: VS2005R2
	Serial Number: 1688-7189-5337-7903-2297-1012-52
	UUID: D29974A4-BE51-044C-BDC6-EFBC4B87A8E9
	Wake-up Type: Power Switch
MSVPC
      @stdout.stub!(:read).and_return(ms_vpc_dmidecode) 
       
      @ohai.stub!(:popen4).with("dmidecode").and_yield(@pid, @stdin, @stdout, @stderr).and_return(@status)
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization][:emulator].should == "virtualpc"
      @ohai[:virtualization][:role].should == "guest"
    end

    it "should set vmware guest if dmidecode detects VMware Virtual Platform" do
      vmware_dmidecode=<<-VMWARE
System Information
	Manufacturer: VMware, Inc.
	Product Name: VMware Virtual Platform
	Version: None
	Serial Number: VMware-50 3f f7 14 42 d1 f1 da-3b 46 27 d0 29 b4 74 1d
	UUID: a86cc405-e1b9-447b-ad05-6f8db39d876a
	Wake-up Type: Power Switch
	SKU Number: Not Specified
	Family: Not Specified
VMWARE
      @stdout.stub!(:read).and_return(vmware_dmidecode)
      @ohai.stub!(:popen4).with("dmidecode").and_yield(@pid, @stdin, @stdout, @stderr).and_return(@status)
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization][:emulator].should == "vmware"
      @ohai[:virtualization][:role].should == "guest"
    end

    it "should run dmidecode and not set virtualization if nothing is detected" do
      @ohai.should_receive(:popen4).with("dmidecode").and_return(true)
      @ohai._require_plugin("linux::virtualization")
      @ohai[:virtualization].should == {}
    end
  end

  it "should not set virtualization if no tests match" do
    @ohai._require_plugin("linux::virtualization")
    @ohai[:virtualization].should == {}
  end
end


