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

describe Ohai::System, "plugin python" do

  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:languages] = Mash.new    
    @ohai.stub!(:require_plugin).and_return(true)
    @status = 0
    @stdout = "2.5.2 (r252:60911, Jan  4 2009, 17:40:26)\n[GCC 4.3.2]\n"
    @stderr = ""
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"python -c \"import sys; print sys.version\""}).and_return([@status, @stdout, @stderr])
  end
  
  it "should get the python version from printing sys.version and sys.platform" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"python -c \"import sys; print sys.version\""}).and_return([0, "2.5.2 (r252:60911, Jan  4 2009, 17:40:26)\n[GCC 4.3.2]\n", ""])
    @ohai._require_plugin("python")
  end

  it "should set languages[:python][:version]" do
    @ohai._require_plugin("python")
    @ohai.languages[:python][:version].should eql("2.5.2")
  end
  
  it "should not set the languages[:python] tree up if python command fails" do
    @status = 1
    @stdout = "2.5.2 (r252:60911, Jan  4 2009, 17:40:26)\n[GCC 4.3.2]\n"
    @stderr = ""
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"python -c \"import sys; print sys.version\""}).and_return([@status, @stdout, @stderr])
    @ohai._require_plugin("python")
    @ohai.languages.should_not have_key(:python)
  end
  
end
