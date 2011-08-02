begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

Before('@nothing_has_this_tag') do
  @vb = :cool
end

Given /^whatever$/ do
end

Then /^VB should not be cool$/ do
  @vb.should_not == :cool
end
