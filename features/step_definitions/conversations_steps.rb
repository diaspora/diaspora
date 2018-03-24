# frozen_string_literal: true

Then /^"([^"]*)" should be part of active conversation$/ do |name|
  within(".conversation-participants") do
    find("img.avatar[title^='#{name}']").should_not be_nil
  end
end

Then /^I should have (\d+) unread private messages?$/ do |n_unread|
  expect(find("header #conversations-link .badge")).to have_content(n_unread)
end

Then /^I should have no unread private messages$/ do
  expect(page).to have_no_css "header #conversations-link .badge"
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  within("#new-conversation", match: :first) do
    find("#contacts-search-input").native.send_key(person.to_s)
    step %(I press the first ".tt-suggestion" within ".twitter-typeahead")
    step %(I fill in "conversation-subject" with "#{subject}")
    step %(I fill in "new-message-text" with "#{text}")
    step %(I press "Send")
  end
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)" using keyboard shortcuts$/ do |subject, text, person|
  step %(I am on the conversations page)
  within("#new-conversation", match: :first) do
    find("#contacts-search-input").native.send_key(person.to_s)
    step %(I press the first ".tt-suggestion" within ".twitter-typeahead")
    step %(I fill in "conversation-subject" with "#{subject}")
    step %(I fill in "new-message-text" with "#{text}")
    find("#new-message-text").native.send_key %i(Ctrl Return)
  end
end

When /^I reply with "([^"]*)"$/ do |text|
  step %(I am on the conversations page)
  step %(I press the first ".conversation" within ".conversations")
  step %(I fill in "response-message-text" with "#{text}")
  step %(I press "Reply")
end

When /^I reply with "([^"]*)" using keyboard shortcuts$/ do |text|
  step %(I am on the conversations page)
  step %(I press the first ".conversation" within ".conversations")
  step %(I fill in "response-message-text" with "#{text}")
  find("#response-message-text").native.send_key %i(Ctrl Return)
end

Then /^I send a mobile message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  step %(I follow "New conversation")
  step %(I fill in "contact_autocomplete" with "#{person}")
  step %(I press the first ".as-result-item" within ".as-results")
  step %(I fill in "conversation-subject" with "#{subject}")
  step %(I fill in "new-message-text" with "#{text}")
  step %(I press "Send")
end

Then /^I should see "([^"]*)" as a participant$/ do |name|
  find(".conversation.stream-element img.avatar[title^='#{name}']").should_not be_nil
end
