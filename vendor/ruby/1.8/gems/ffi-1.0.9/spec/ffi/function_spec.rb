#
# This file is part of ruby-ffi.
#
# This code is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License version 3 only, as
# published by the Free Software Foundation.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# version 3 for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# version 3 along with this work.  If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe FFI::Function do
  before do
    module LibTest
      extend FFI::Library
      ffi_lib TestLibrary::PATH
      attach_function :testFunctionAdd, [:int, :int, :pointer], :int
    end
    @libtest = FFI::DynamicLibrary.open(TestLibrary::PATH, 
                                        FFI::DynamicLibrary::RTLD_LAZY | FFI::DynamicLibrary::RTLD_GLOBAL)
  end
  it 'is initialized with a signature and a block' do
    FFI::Function.new(:int, []) { }
  end
  it 'raises an error when passing a wrong signature' do
    lambda { FFI::Function.new([], :int).new { } }.should raise_error TypeError 
  end
  it 'returns a native pointer' do
    FFI::Function.new(:int, []) { }.kind_of? FFI::Pointer
  end
  it 'can be used as callback from C passing to it a block' do
    function_add = FFI::Function.new(:int, [:int, :int]) { |a, b| a + b }
    LibTest.testFunctionAdd(10, 10, function_add).should == 20
  end
  it 'can be used as callback from C passing to it a Proc object' do
    function_add = FFI::Function.new(:int, [:int, :int], Proc.new { |a, b| a + b })
    LibTest.testFunctionAdd(10, 10, function_add).should == 20
  end
  it 'can be used to wrap an existing function pointer' do
    FFI::Function.new(:int, [:int, :int], @libtest.find_function('testAdd')).call(10, 10).should == 20
  end
  it 'can be attached to a module' do
    module Foo; end
    fp = FFI::Function.new(:int, [:int, :int], @libtest.find_function('testAdd'))
    fp.attach(Foo, 'add')
    Foo.add(10, 10).should == 20
  end
  it 'can be used to extend an object' do
    fp = FFI::Function.new(:int, [:int, :int], @libtest.find_function('testAdd'))
    foo = Object.new
    class << foo
      def singleton_class
        class << self; self; end
      end
    end
    fp.attach(foo.singleton_class, 'add')
    foo.add(10, 10).should == 20    
  end
  it 'can wrap a blocking function' do
    fp = FFI::Function.new(:void, [ :int ], @libtest.find_function('testBlocking'), :blocking => true)
    time = Time.now
    threads = []
    threads << Thread.new { fp.call(2) }
    threads << Thread.new(time) { (Time.now - time).should < 1 }
    threads.each { |t| t.join }
  end
  it 'autorelease flag is set to true by default' do
    fp = FFI::Function.new(:int, [:int, :int], @libtest.find_function('testAdd'))
    fp.autorelease?.should be_true
  end
  it 'can explicity free itself' do
    fp = FFI::Function.new(:int, []) { }
    fp.free
    lambda { fp.free }.should raise_error RuntimeError
  end
  it 'can\'t explicity free itself if not previously allocated' do
    fp = FFI::Function.new(:int, [:int, :int], @libtest.find_function('testAdd'))
    lambda { fp.free }.should raise_error RuntimeError
  end
end
