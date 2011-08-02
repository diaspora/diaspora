require 'spec_helper'
require 'extlib/virtual_file'

describe VirtualFile do
  it 'inherits from StringIO' do
    VirtualFile.superclass.should == StringIO
  end

  it 'has path reader' do
    @vf = VirtualFile.new("virtual", "elvenpath")

    # =~ /#{Dir::tmpdir}/ causes RegExp to fail with nested *?+ on 1.8.6
    @vf.path.should == "elvenpath"
  end

  it 'has path writer' do
    @vf = VirtualFile.new("virtual", "elvenpath")

    @vf.path = "newbase"
    @vf.path.should == "newbase"
  end
end
