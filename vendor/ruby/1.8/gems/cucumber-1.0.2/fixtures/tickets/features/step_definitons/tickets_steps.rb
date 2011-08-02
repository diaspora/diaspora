begin require 'rspec/expectations'; rescue LoadError; require 'spec/expectations'; end

Given "be_empty" do
  [1,2].should_not be_empty
end

Given "nested step is called" do
  Given "I like mushroom", Cucumber::Ast::Table.new([
    %w{sponge bob},
    %w{is cool}
  ])
end

Given 'nested step is called using text table' do
  Given "I like mushroom", table(%{
    | sponge | bob  |
    | is     | cool |
  })

  # Alternative syntax (file and line will be reported on parse error)
  # Given "I like mushroom", table(<<-EOT, __FILE__, __LINE__)
  #   | sponge | bob  |
  #   | is     | cool
  # EOT
end

Given "I like $what" do |what, table|
  @magic = what
  @tool  = table.raw[0][0]
end

Then "nested step should be executed" do
  @magic.should == 'mushroom'
  @tool.should == 'sponge'
end

Given /^the following table$/ do |table|
  @table = table
end

Then /^I should be (\w+) in (\w+)$/ do |key, value|
  hash = @table.hashes[0]
  hash[key].should == value
end

Then /^I should see a multiline string like$/ do |s|
  s.should == %{A string
that spans
several lines}
end

Given /^the following users exist in the system$/ do |table|
  table.hashes[0][:role_assignments].should == 'HUMAN RESOURCE'
end

Given /^I have a pending step$/ do
  pending
end

Given /^I have (\d+) cukes in my belly$/ do |arg1|
end

Given /^I call empty steps$/ do
  steps ""
end

When /^I run this feature with the progress format$/ do
  pending
end

Then /^I should get a no method error for 'backtrace_line'$/ do
  pending
end

Then /the table should be different with table:/ do |expected|
  expected.diff!(table(%{
    | b     | c    | a     | d |
    | KASHA | AIIT | BOOYA | X |
    | four  | five | three | Y |
  }), :coldiff => true)
end

Then /the table should be different with array:/ do |expected|
  expected.diff!([
    {'a' => 'BOOYA', 'b' => 'KASHA'},
    {'a' => 'three', 'b' => 'four'},
  ])
end