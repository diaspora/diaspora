require 'spec_helper'
require 'extlib/module'

describe Module do

  before(:all) do
    module ::Foo
      module ModBar
        module Noo
          module Too
            module Boo
            end
          end
        end
      end

      class Zed
      end
    end

    class ::Bas
    end

    class ::Bar
    end
  end

  it "should raise NameError for a missing constant" do
    lambda { Foo.find_const('Moo') }.should raise_error(NameError)
    lambda { Object.find_const('MissingConstant') }.should raise_error(NameError)
  end

  it "should be able to get a recursive constant" do
    Object.find_const('Foo::ModBar').should == Foo::ModBar
  end

  it "should ignore get Constants from the Kernel namespace correctly" do
    Object.find_const('::Foo::ModBar').should == ::Foo::ModBar
  end

  it "should find relative constants" do
    Foo.find_const('ModBar').should == Foo::ModBar
    Foo.find_const('Bas').should == Bas
  end

  it "should find sibling constants" do
    Foo::ModBar.find_const("Zed").should == Foo::Zed
  end

  it "should find nested constants on nested constants" do
    Foo::ModBar.find_const('Noo::Too').should == Foo::ModBar::Noo::Too
  end

  it "should find constants outside of nested constants" do
    Foo::ModBar::Noo::Too.find_const("Zed").should == Foo::Zed
  end

  it 'should be able to find past the second nested level' do
    Foo::ModBar::Noo.find_const('Too').should == Foo::ModBar::Noo::Too
    Foo::ModBar::Noo::Too.find_const('Boo').should == Foo::ModBar::Noo::Too::Boo
  end


  it "should be able to deal with constants being added and removed" do
    Object.find_const('Bar') # First we load Bar with find_const
    Object.module_eval { remove_const('Bar') } # Now we delete it
    module ::Bar; end; # Now we redefine it
    Object.find_const('Bar').should == Bar
  end

end
