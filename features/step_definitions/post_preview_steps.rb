# frozen_string_literal: true

And /^I edit the post$/ do
  with_scope(".publisher-textarea-wrapper") do
    find(".md-write-tab").click
  end
end

Then /^the preview should not be collapsed$/ do
  with_scope(".publisher-textarea-wrapper .collapsible") do
    expect(current_scope).not_to have_css(".collapsed")
  end
end

And /^I preview the post$/ do
  with_scope(".publisher-textarea-wrapper") do
    find(".md-preview-tab").click
  end
end

Then /^I should see "([^"]*)" in the preview$/ do |text|
  with_scope(".publisher-textarea-wrapper .md-preview") do
    expect(current_scope).to have_content(text)
  end
end

Then /^I should not see "([^"]*)" in the preview$/ do |text|
  with_scope(".publisher-textarea-wrapper .md-preview") do
    expect(current_scope).to_not have_content(text)
  end
end

Then /^I should not be in preview mode$/ do
  with_scope(".publisher-textarea-wrapper") do
    expect(current_scope).to_not have_css(".md-preview")
  end
end
