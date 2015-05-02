Then /^"([^"]*)" should be part of active conversation$/ do |name|
  within(".conversation_participants") do
    find("img.avatar[title^='#{name}']").should_not be_nil
  end
end

Then /^I should have (\d+) unread private messages?$/ do |n_unread|
  find("header #conversations_badge .badge_count").should have_content(n_unread)
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  within("#conversation_new", match: :first) do
    step %(I fill in "contact_autocomplete" with "#{person}")
    step %(I press the first ".as-result-item" within ".as-results")
    step %(I fill in "conversation_subject" with "#{subject}")
    step %(I fill in "conversation_text" with "#{text}")
    step %(I press "Send")
  end
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)" using keyboard shortcuts$/ do |subject, text, person|
  step %(I am on the conversations page)
  within("#conversation_new", match: :first) do
    step %(I fill in "contact_autocomplete" with "#{person}")
    step %(I press the first ".as-result-item" within ".as-results")
    step %(I fill in "conversation_subject" with "#{subject}")
    step %(I fill in "conversation_text" with "#{text}")
    find("#conversation_text").native.send_keys :control, :return
  end
end

When /^I reply with "([^"]*)"$/ do |text|
  step %(I am on the conversations page)
  step %(I press the first ".conversation" within ".conversations")
  step %(I fill in "message_text" with "#{text}")
  step %(I press "Reply")
end

When /^I reply with "([^"]*)" using keyboard shortcuts$/ do |text|
  step %(I am on the conversations page)
  step %(I press the first ".conversation" within ".conversations")
  step %(I fill in "message_text" with "#{text}")
  find("#message_text").native.send_keys :control, :return
end

Then /^I send a mobile message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  step %(I follow "New conversation")
  step %(I fill in "contact_autocomplete" with "#{person}")
  step %(I press the first ".as-result-item" within ".as-results")
  step %(I fill in "conversation_subject" with "#{subject}")
  step %(I fill in "conversation_text" with "#{text}")
  step %(I press "Send")
end

Then /^I should see "([^"]*)" as a participant$/ do |name|
  find(".conversation.stream_element img.avatar[title^='#{name}']").should_not be_nil
end
