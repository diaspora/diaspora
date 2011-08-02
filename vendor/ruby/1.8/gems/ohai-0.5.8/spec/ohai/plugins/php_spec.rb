#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2009 VMware, Inc.
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

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper.rb'))

describe Ohai::System, "plugin php" do

  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:languages] = Mash.new
    @ohai.stub!(:require_plugin).and_return(true)
    @status = 0
    @stdout = "PHP 5.1.6 (cli) (built: Jul 16 2008 19:52:52)\nCopyright (c) 1997-2006 The PHP Group\nZend Engine v2.1.0, Copyright (c) 1998-2006 Zend Technologies\n"
    @stderr = ""
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"php -v"}).and_return([@status, @stdout, @stderr])
  end

  it "should get the php version from running php -V" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"php -v"}).and_return([0, "PHP 5.1.6 (cli) (built: Jul 16 2008 19:52:52)\nCopyright (c) 1997-2006 The PHP Group\nZend Engine v2.1.0, Copyright (c) 1998-2006 Zend Technologies\n", ""])
    @ohai._require_plugin("php")
  end

  it "should set languages[:php][:version]" do
    @ohai._require_plugin("php")
    @ohai.languages[:php][:version].should eql("5.1.6")
  end

  it "should not set the languages[:php] tree up if php command fails" do
    @status = 1
    @stdout = "PHP 5.1.6 (cli) (built: Jul 16 2008 19:52:52)\nCopyright (c) 1997-2006 The PHP Group\nZend Engine v2.1.0, Copyright (c) 1998-2006 Zend Technologies\n"
    @stderr = ""
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"php -v"}).and_return([@status, @stdout, @stderr])
    @ohai._require_plugin("php")
    @ohai.languages.should_not have_key(:php)
  end

end
