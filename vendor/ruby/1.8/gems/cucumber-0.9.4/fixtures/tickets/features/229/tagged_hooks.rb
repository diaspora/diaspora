begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

Before('@i_am_so_special') do
  @something_special = 10
end

After('@i_am_so_special') do
  @something_special.should == 20
end

When /special me goes to town/ do
  @something_special.should == 10
  @something_special = 20
end