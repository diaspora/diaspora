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


require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')

describe Ohai::System, "Linux cpu plugin" do
  before(:each) do
    @ohai = Ohai::System.new    
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:os] = "linux"
    @mock_file = mock("/proc/cpuinfo")
    @mock_file.stub!(:each).
      and_yield("processor     : 0").
      and_yield("vendor_id     : GenuineIntel").
      and_yield("cpu family    : 6").
      and_yield("model         : 23").
      and_yield("model name    : Intel(R) Core(TM)2 Duo CPU     T8300   @ 2.40GHz").
      and_yield("stepping      : 6").
      and_yield("cpu MHz       : 1968.770").
      and_yield("cache size    : 64 KB").
      and_yield("fdiv_bug      : no").
      and_yield("hlt_bug       : no").
      and_yield("f00f_bug      : no").
      and_yield("coma_bug      : no").
      and_yield("fpu           : yes").
      and_yield("fpu_exception : yes").
      and_yield("cpuid level   : 10").
      and_yield("wp            : yes").
      and_yield("flags         : fpu pse tsc msr mce cx8 sep mtrr pge cmov").
      and_yield("bogomips      : 2575.86").
      and_yield("clflush size  : 32")
    File.stub!(:open).with("/proc/cpuinfo").and_return(@mock_file)
  end
  
  it "should set cpu[:total] to 1" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu][:total].should == 1
  end
  
  it "should set cpu[:real] to 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu][:real].should == 0
  end
  
  it "should have a cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu].should have_key("0")
  end
  
  it "should have a vendor_id for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("vendor_id")
    @ohai[:cpu]["0"]["vendor_id"].should eql("GenuineIntel")
  end
  
  it "should have a family for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("family")
    @ohai[:cpu]["0"]["family"].should eql("6")
  end
  
  it "should have a model for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("model")
    @ohai[:cpu]["0"]["model"].should eql("23")
  end
  
  it "should have a stepping for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("stepping")
    @ohai[:cpu]["0"]["stepping"].should eql("6")
  end
  
  it "should not have a phyiscal_id for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should_not have_key("physical_id")
  end
  
  it "should not have a core_id for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should_not have_key("core_id")
  end
  
  it "should not have a cores for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should_not have_key("cores")
  end
  
  it "should have a model name for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("model_name")
    @ohai[:cpu]["0"]["model_name"].should eql("Intel(R) Core(TM)2 Duo CPU     T8300   @ 2.40GHz")
  end
  
  it "should have a mhz for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("mhz")
    @ohai[:cpu]["0"]["mhz"].should eql("1968.770")
  end
  
  it "should have a cache_size for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("cache_size")
    @ohai[:cpu]["0"]["cache_size"].should eql("64 KB")
  end
  
  it "should have flags for cpu 0" do
    @ohai._require_plugin("linux::cpu")
    @ohai[:cpu]["0"].should have_key("flags")
    @ohai[:cpu]["0"]["flags"].should == %w{fpu pse tsc msr mce cx8 sep mtrr pge cmov}
  end
end