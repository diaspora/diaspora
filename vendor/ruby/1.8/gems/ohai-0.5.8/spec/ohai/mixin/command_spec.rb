#
# Author:: Diego Algorta (diego@oboxodo.com)
# Copyright:: Copyright (c) 2009 Diego Algorta
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

describe Ohai::Mixin::Command, "popen4" do
  break if RUBY_PLATFORM =~ /(win|w)32$/

  it "should default all commands to be run in the POSIX standard C locale" do
    Ohai::Mixin::Command.popen4("echo $LC_ALL") do |pid, stdin, stdout, stderr|
      stdin.close
      stdout.read.strip.should == "C"
    end
  end

  it "should respect locale when specified explicitly" do
    Ohai::Mixin::Command.popen4("echo $LC_ALL", :environment => {"LC_ALL" => "es"}) do |pid, stdin, stdout, stderr|
      stdin.close
      stdout.read.strip.should == "es"
    end
  end

end
