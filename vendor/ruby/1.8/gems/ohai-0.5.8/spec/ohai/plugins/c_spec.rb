#
# Author:: Doug MacEachern <dougm@vmware.com>
# Copyright:: Copyright (c) 2010 VMware, Inc.
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

require 'rbconfig'

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper.rb'))

C_GCC = <<EOF
Reading specs from /usr/lib/gcc/x86_64-redhat-linux/3.4.6/specs
Configured with: ../configure --prefix=/usr ... --host=x86_64-redhat-linux
Thread model: posix
gcc version 3.4.6 20060404 (Red Hat 3.4.6-3)
EOF

C_GLIBC = <<EOF
GNU C Library stable release version 2.3.4, by Roland McGrath et al.
Copyright (C) 2005 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
Compiled by GNU CC version 3.4.6 20060404 (Red Hat 3.4.6-3).
Compiled on a Linux 2.4.20 system on 2006-08-12.
Available extensions:
        GNU libio by Per Bothner
        crypt add-on version 2.1 by Michael Glad and others
        linuxthreads-0.10 by Xavier Leroy
        The C stubs add-on version 2.1.2.
        BIND-8.2.3-T5B
        NIS(YP)/NIS+ NSS modules 0.19 by Thorsten Kukuk
        Glibc-2.0 compatibility add-on by Cristian Gafton 
        GNU Libidn by Simon Josefsson
        libthread_db work sponsored by Alpha Processor Inc
Thread-local storage support included.
For bug reporting instructions, please see:
<http://www.gnu.org/software/libc/bugs.html>.
EOF

C_CL = <<EOF
Microsoft (R) 32-bit C/C++ Optimizing Compiler Version 14.00.50727.762 for 80x86
Copyright (C) Microsoft Corporation.  All rights reserved.
EOF

C_VS = <<EOF

Microsoft (R) Visual Studio Version 8.0.50727.762.
Copyright (C) Microsoft Corp 1984-2005. All rights reserved.
EOF

C_XLC = <<EOF
IBM XL C/C++ Enterprise Edition for AIX, V9.0
Version: 09.00.0000.0000
EOF

C_SUN = <<EOF
cc: Sun C 5.8 Patch 121016-06 2007/08/01
EOF

C_HPUX = <<EOF
/opt/ansic/bin/cc:
        $Revision: 92453-07 linker linker crt0.o B.11.47 051104 $
        LINT B.11.11.16 CXREF B.11.11.16
        HP92453-01 B.11.11.16 HP C Compiler
         $ PATCH/11.00:PHCO_27774  Oct  3 2002 09:45:59 $ 
EOF

describe Ohai::System, "plugin c" do

  before(:each) do
    @ohai = Ohai::System.new
    @ohai[:languages] = Mash.new
    @ohai.stub!(:require_plugin).and_return(true)
    #gcc
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"gcc -v"}).and_return([0, "", C_GCC])
    #glibc
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"/lib/libc.so.6"}).and_return([0, C_GLIBC, ""])
    #ms cl
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"cl /\?"}).and_return([0, "", C_CL])
    #ms vs
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"devenv.com /\?"}).and_return([0, C_VS, ""])
    #ibm xlc
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"xlc -qversion"}).and_return([0, C_XLC, ""])
    #sun pro
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"cc -V -flags"}).and_return([0, "", C_SUN])
    #hpux cc
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"what /opt/ansic/bin/cc"}).and_return([0, C_HPUX, ""])
  end

  #gcc
  it "should get the gcc version from running gcc -v" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"gcc -v"}).and_return([0, "", C_GCC])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:gcc][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:gcc][:version].should eql("3.4.6")
  end

  it "should set languages[:c][:gcc][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:gcc][:description].should eql(C_GCC.split($/).last)
  end

  it "should not set the languages[:c][:gcc] tree up if gcc command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"gcc -v"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:gcc) if @ohai[:languages][:c]
  end

  #glibc
  it "should get the glibc version from running gcc -v" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"/lib/libc.so.6"}).and_return([0, C_GLIBC, ""])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:glibc][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:glibc][:version].should eql("2.3.4")
  end

  it "should set languages[:c][:glibc][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:glibc][:description].should eql(C_GLIBC.split($/).first)
  end

  it "should not set the languages[:c][:glibc] tree up if glibc command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"/lib/libc.so.6"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:glibc) if @ohai[:languages][:c]
  end

  #ms cl
  it "should get the cl version from running cl /?" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"cl /\?"}).and_return([0, "", C_CL])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:cl][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:cl][:version].should eql("14.00.50727.762")
  end

  it "should set languages[:c][:cl][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:cl][:description].should eql(C_CL.split($/).first)
  end

  it "should not set the languages[:c][:cl] tree up if cl command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"cl /\?"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:cl) if @ohai[:languages][:c]
  end

  #ms vs
  it "should get the vs version from running devenv.com /?" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"devenv.com /\?"}).and_return([0, C_VS, ""])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:vs][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:vs][:version].should eql("8.0.50727.762")
  end

  it "should set languages[:c][:vs][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:vs][:description].should eql(C_VS.split($/)[1])
  end

  it "should not set the languages[:c][:vs] tree up if devenv command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"devenv.com /\?"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:vs) if @ohai[:languages][:c]
  end

  #ibm xlc
  it "should get the xlc version from running xlc -qversion" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"xlc -qversion"}).and_return([0, C_XLC, ""])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:xlc][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:xlc][:version].should eql("09.00.0000.0000")
  end

  it "should set languages[:c][:xlc][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:xlc][:description].should eql(C_XLC.split($/).first)
  end

  it "should not set the languages[:c][:xlc] tree up if xlc command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"xlc -qversion"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:xlc) if @ohai[:languages][:c]
  end

  #sun pro
  it "should get the cc version from running cc -V -flags" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"cc -V -flags"}).and_return([0, "", C_SUN])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:sunpro][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:sunpro][:version].should eql("5.8")
  end

  it "should set languages[:c][:sunpro][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:sunpro][:description].should eql(C_SUN.chomp)
  end

  it "should not set the languages[:c][:sunpro] tree up if cc command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"cc -V -flags"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:sunpro) if @ohai[:languages][:c]
  end

  #hpux cc
  it "should get the cc version from running what cc" do
    @ohai.should_receive(:run_command).with({:no_status_check=>true, :command=>"what /opt/ansic/bin/cc"}).and_return([0, C_HPUX, ""])
    @ohai._require_plugin("c")
  end

  it "should set languages[:c][:hpcc][:version]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:hpcc][:version].should eql("B.11.11.16")
  end

  it "should set languages[:c][:hpcc][:description]" do
    @ohai._require_plugin("c")
    @ohai.languages[:c][:hpcc][:description].should eql(C_HPUX.split($/)[3].strip)
  end

  it "should not set the languages[:c][:hpcc] tree up if cc command fails" do
    @ohai.stub!(:run_command).with({:no_status_check=>true, :command=>"what /opt/ansic/bin/cc"}).and_return([1, "", ""])
    @ohai._require_plugin("c")
    @ohai[:languages][:c].should_not have_key(:hpcc) if @ohai[:languages][:c]
  end
end
