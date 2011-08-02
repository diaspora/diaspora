require 'ap' # awesome_print gem
require 'stringio'
require 'gherkin/formatter/json_formatter'
require 'gherkin/listener/formatter_listener'

# Monkey patching so that Hash.to_json has a predictable result.
class Hash
  alias orig_keys keys
  def keys
    orig_keys.sort
  end
end

Given /^a JSON formatter$/ do
  @io = StringIO.new
  @formatter = Gherkin::Formatter::JSONFormatter.new(@io)
end

Then /^the outputted JSON should be:$/ do |expected_json|
  require 'json'
  puts JSON.pretty_generate(JSON.parse(@io.string))
  expected = JSON.parse(expected_json).ai
  actual   = JSON.parse(@io.string).ai
  actual.should == expected
end



