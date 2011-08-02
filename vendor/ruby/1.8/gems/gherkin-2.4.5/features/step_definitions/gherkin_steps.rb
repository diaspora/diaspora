Given /^a "(ruby|native)" "([^\"]*)" parser$/ do |ruby_or_native, parser_name|
  @parser = Gherkin::Parser::Parser.new(@formatter, false, parser_name, ruby_or_native=="ruby")
end

Given "the following text is parsed:" do |text|
  @parser.parse(text, "test.feature", 0)
end

Then "there should be no parse errors" do
  @formatter.errors.should == []
end

Then /^there should be a parse error on (line \d+)$/ do |line|
  @formatter.line(line).should include(:syntax_error, line)
end

Then /^there should be parse errors on (lines .*)$/ do |lines|
  lines.each do |line|
    Then "there should be a parse error on line #{line}"
  end
end

Transform /^line \d+$/ do |step_arg|
  tr_line_number(step_arg)
end

Transform /^lines .*$/ do |step_arg|
  tr_line_numbers(step_arg)
end
