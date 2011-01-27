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

And /^I hover over the post$/ do
  page.execute_script('$(".stream_element").first().mouseover()')
end

And /^I preemptively confirm the alert$/ do
  a = page.evaluate_script("window.confirm = function() { return true; }")
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
Then /^(?:|I )should see a "([^"]*)"(?: within "([^"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    page.has_css?(selector).should be_true
  end
end
Then /^I should see "([^\"]*)" in the main content area$/ do |stuff|
  within("#main_stream") do
    Then "I should see #{stuff}"
  end
end

When /^I wait for the aspects page to load$/ do
  wait_until { current_path == aspects_path }
end

When /^I wait for the request's profile page to load$/ do
  wait_until { current_path == person_path(Request.where(:recipient_id => @me.person.id).first.sender) }
end

When /^I wait for the ajax to finish$/ do
  wait_until(10) { evaluate_script("$.active") == 0 }
end

When /^I have turned off jQuery effects$/ do
  evaluate_script("$.fx.off = true")
end

When /^I click ok in the confirm dialog to appear next$/ do
  evaluate_script <<-JS
    window.confirm = function() { return true; };    
  JS
end
