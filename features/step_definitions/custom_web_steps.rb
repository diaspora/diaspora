When /^(.*) in the header$/ do |action|
  within('header') do
    When action
  end
end

And /^I expand the publisher$/ do
  page.execute_script('
    $("#publisher").removeClass("closed");
    $("#publisher").find("textarea").focus();
    ')
end


When /^(?:|I )append "([^"]*)" with "([^"]*)"$/ do |field, value|
  script = "$('#{ field }').val(function(index, value) {
  return value + ' ' + '#{value}'; });"
   page.execute_script(script)
end

And /^I hover over the post$/ do
  page.execute_script('$(".stream_element").first().mouseover()')
end

When /^I click to delete the first post$/ do
  page.execute_script('$(".stream_element").first().find(".delete").click()')
end

And /^I click "([^"]*)" button$/ do |arg1|
  page.execute_script('$(".button:contains('+arg1+')").click()')
end

And /^I preemptively confirm the alert$/ do
  page.evaluate_script("window.confirm = function() { return true; }")
end

And /^I preemptively reject the alert$/ do
  page.evaluate_script("window.confirm = function() { return false; }")
end

When /^(.*) in the modal window$/ do |action|
  within('#facebox') do
    When action
  end
end

When /^(.*) in the aspect list$/ do |action|
  within('#aspect_list') do
    When action
  end
end

When /^I press the first "([^"]*)"(?: within "([^"]*)")?$/ do |link_selector, within_selector|
  with_scope(within_selector) do
   find(:css, link_selector).click
  end
end

When /^I press the ([\d])(nd|rd|st|th) "([^\"]*)"(?: within "([^\"]*)")?$/ do |number,rd, link_selector, within_selector|
  with_scope(within_selector) do
   find(:css, link_selector+":nth-child(#{number})").click
  end
end
Then /^(?:|I )should see a "([^\"]*)"(?: within "([^\"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    page.has_css?(selector).should be_true
  end
end
Then /^I should see "([^\"]*)" in the main content area$/ do |stuff|
  within("#main_stream") do
    Then "I should see #{stuff}"
  end
end

When /^I wait for the ajax to finish$/ do
  wait_until(10) { evaluate_script("$.active") == 0 }
end

When /^I have turned off jQuery effects$/ do
  evaluate_script("$.fx.off = true")
end

When /^I attach the file "([^\"]*)" to hidden element "([^\"]*)"(?: within "([^\"]*)")?$/ do |path, field, selector|
  page.execute_script <<-JS
    $("#{selector || 'body'}").find("input[name=#{field}]").css({opacity: 1});
  JS

  if selector
    When "I attach the file \"#{Rails.root.join(path).to_s}\" to \"#{field}\" within \"#{selector}\""
  else
    When "I attach the file \"#{Rails.root.join(path).to_s}\" to \"#{field}\""
  end

  page.execute_script <<-JS
    $("#{selector || 'body'}").find("input[name=#{field}]").css({opacity: 0});
  JS
end

When /^I click ok in the confirm dialog to appear next$/ do
  evaluate_script <<-JS
    window.confirm = function() { return true; };
  JS
end

When /^I wait for "([^\"]*)" to load$/ do |page_name|
  wait_until(10) do
    uri = URI.parse(current_url)
    current_location = uri.path
    current_location << "?#{uri.query}" unless uri.query.blank?
    current_location == path_to(page_name)
  end
end
