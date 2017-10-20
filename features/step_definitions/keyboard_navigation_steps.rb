# frozen_string_literal: true

When /^I press the "([^\"]*)" key somewhere$/ do |key|
  within("#main-stream") do
    find("div.stream-element", match: :first).native.send_keys(key)
  end
end

When /^I press the "([^\"]*)" key in the publisher$/ do |key|
  find("#status_message_text").native.send_key(key)
end

Then /^post (\d+) should be highlighted$/ do |position|
  find(".shortcut_selected .post-content").text.should == stream_element_numbers_content(position).text
end

And /^I should have navigated to the highlighted post$/ do
  expect(page.evaluate_script("window.pageYOffset + 60 - $('.shortcut_selected').offset().top").to_i).to be(0)
end
