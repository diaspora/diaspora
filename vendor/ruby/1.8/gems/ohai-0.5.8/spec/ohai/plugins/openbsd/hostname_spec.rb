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

describe Ohai::System, "OpenBSD hostname plugin" do
  before(:each) do
    @ohai = Ohai::System.new    
    @ohai.stub!(:require_plugin).and_return(true)
    @ohai[:os] = "openbsd"
    @ohai.stub!(:from).with("hostname -s").and_return("katie")
    @ohai.stub!(:from).with("hostname").and_return("katie.bethell")
  end
  
  it_should_check_from("openbsd::hostname", "hostname", "hostname -s", "katie")
  
  it_should_check_from("openbsd::hostname", "fqdn", "hostname", "katie.bethell")
end
