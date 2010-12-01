require 'stringio'
require 'gherkin/formatter/pretty_formatter'
require 'gherkin/json_parser'

World(Gherkin::Formatter::Colors)

Given /^a PrettyFormatter$/ do
  @io = StringIO.new
  @formatter = Gherkin::Formatter::PrettyFormatter.new(@io, true)
end

Given /^a JSON lexer$/ do
  @json_parser = Gherkin::JSONParser.new(@formatter)
end

Given /^the following JSON is parsed:$/ do |text|
  @json_parser.parse(JSON.pretty_generate(JSON.parse(text)), "unknown.json", 0)
end

Then /^the outputted text should be:$/ do |expected_text|
  @io.string.strip.should == expected_text
end
