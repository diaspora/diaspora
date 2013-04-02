When /^I press the "([^\"]*)" key somewhere$/ do |key|
  find("div.stream_element").native.send_keys(key)
end

When /^I press the "([^\"]*)" key in the publisher$/ do |key|
  find("#status_message_fake_text").native.send_keys(key)                    
end

Then /^post (\d+) should be highlighted$/ do |position|
  find(".shortcut_selected .post-content").text.should == stream_element_numbers_content(position).text
end

And /^I should have navigated to the highlighted post$/ do
  find(".shortcut_selected")["offsetTop"].to_i.should == page.evaluate_script("window.pageYOffset + 50").to_i
end

When /^I scroll to post (\d+)$/ do |position|
  page.driver.browser.execute_script("var element = $('div.stream_element')[" + position + " - 1];
  window.scrollTo(window.pageXOffset, element.offsetTop-50);")
end
