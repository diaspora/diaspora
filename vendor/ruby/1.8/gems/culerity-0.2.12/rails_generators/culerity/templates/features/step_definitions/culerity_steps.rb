require 'culerity'

Before do
  $rails_server_pid ||= Culerity::run_rails(:environment => 'culerity', :port => 3001)
  $server ||= Culerity::run_server
  unless $browser
    $browser = Culerity::RemoteBrowserProxy.new $server, {:browser => :firefox3,
      :javascript_exceptions => true,
      :resynchronize => true,
      :status_code_exceptions => true
    }
    $browser.log_level = :warning
  end
  @host = 'http://localhost:3001'
end

After do
  $server.clear_proxies
  $browser.clear_cookies
end

at_exit do
  $browser.exit if $browser
  $server.close if $server
  Process.kill(6, $rails_server_pid) if $rails_server_pid
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  $browser.goto @host + path_to(page_name)
end

When /I follow "([^\"]*)"/ do |link|
  _link = [
    [:text, /^#{Regexp.escape(link)}$/ ], 
    [:id, link], 
    [:title, link],
    [:text, /#{Regexp.escape(link)}/ ], 
  ].map{|args| $browser.link(*args)}.find{|__link| __link.exist?}
  raise "link \"#{link}\" not found" unless _link
  _link.click
  assert_successful_response
end

When /I press "([^\"]*)"/ do |button|
  $browser.button(:text, button).click
  assert_successful_response
end

When /I fill in "([^\"]*)" with "([^\"]*)"/ do |field, value|
  find_by_label_or_id(:text_field, field).set(value)
end

When /I fill in "([^\"]*)" for "([^\"]*)"/ do |value, field|
  find_by_label_or_id(:text_field, field).set(value)
end

When /I check "([^\"]*)"/ do |field|
  find_by_label_or_id(:check_box, field).set(true)
end

When /^I uncheck "([^\"]*)"$/ do |field|
  find_by_label_or_id(:check_box, field).set(false)
end

When /I select "([^\"]*)" from "([^\"]*)"/ do |value, field|
  find_by_label_or_id(:select_list, field).select value
end

When /I choose "([^\"]*)"/ do |field|
  find_by_label_or_id(:radio, field).set(true)
end

When /I go to (.+)/ do |path|
  $browser.goto @host + path_to(path)
  assert_successful_response
end

When /^I wait for the AJAX call to finish$/ do
  $browser.wait_while do
    begin
      count = $browser.execute_script("window.running_ajax_calls").to_i
      count.to_i > 0
    rescue => e
      if e.message.include?('HtmlunitCorejsJavascript::Undefined')
        raise "For 'I wait for the AJAX call to finish' to work please include culerity.js after including jQuery. If you don't use jQuery please rewrite culerity.js accordingly."
      else
        raise(e)
      end
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse($browser.url)
  expected_path = URI.parse(path_to(page_name))

  # If our expected path doesn't specify a query-string, ignore any query string
  # in the current path 
  current_path, expected_path = if expected_path.query.nil? 
    [ current_path.path, expected_path.path ]
  else
    [ current_path.select(:path, :query).compact.join('?'), path_to(page_name) ]
  end

  if defined?(Spec::Rails::Matchers)
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^the "([^\"]*)" field should contain "([^\"]*)"$/ do |field, value|
  f = find_by_label_or_id(:text_field, field)
  if defined?(Spec::Rails::Matchers)
    f.text.should =~ /#{Regexp::escape(value)}/
  else
    assert_match(/#{Regexp::escape(value)}/, f.text)
  end
end

Then /^the "([^\"]*)" field should not contain "([^\"]*)"$/ do |field, value|
  f = find_by_label_or_id(:text_field, field)
  if defined?(Spec::Rails::Matchers)
    f.text.should_not =~ /#{Regexp::escape(value)}/
  else
    assert_no_match(/#{Regexp::escape(value)}/, f.text)
  end
end

Then /^the "([^\"]*)" checkbox should be checked$/ do |label|
  f = find_by_label_or_id(:check_box, label)
  if defined?(Spec::Rails::Matchers)
    f.should be_checked
  else
    assert f.checked?
  end
end

Then /^the "([^\"]*)" checkbox should not be checked$/ do |label|
  f = find_by_label_or_id(:check_box, label)
  if defined?(Spec::Rails::Matchers)
   f.should_not be_checked
  else
    assert !f.checked?
  end
end

Then /I should see "([^\"]*)"/ do |text|
  $browser.text.include?(text).should be_true
end

Then /I should not see "([^\"]*)"/ do |text|
  $browser.text.include?(text).should_not be_true
end

def find_by_label_or_id(element, attribute)
  matchers = [[attribute, :id], [attribute, :name]]
  matchers << [$browser.label(:text, attribute).for, :id] if $browser.label(:text, attribute).exist?
  field = matchers.map{|_field, matcher| $browser.send(element, matcher, _field)}.find(&:exist?) ||  raise("#{element} not found using  \"#{attribute}\"")
end

def assert_successful_response
  status = $browser.page.web_response.status_code
  if(status == 302 || status == 301)
    location = $browser.page.web_response.get_response_header_value('Location')
    puts "Being redirected to #{location}"
    $browser.goto location
    assert_successful_response
  elsif status != 200
    filename = "culerity-#{Time.now.to_i}.html"
    File.open(RAILS_ROOT + "/tmp/#{filename}", "w") do |f|
      f.write $browser.html
    end
    `open tmp/#{filename}`
    raise "Browser returned Response Code #{$browser.page.web_response.status_code}"
  end
end
