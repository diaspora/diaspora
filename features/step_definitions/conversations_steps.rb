Then /^"([^"]*)" should be part of active conversation$/ do |name|
  within(".conversation_participants") do
    find("img.avatar[title^='#{name}']").should_not be_nil
  end
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  step %(I follow "New Message")
  step %(I wait for the ajax to finish)
  step %(I fill in "contact_autocomplete" with "#{person}" in the modal window)
  step %(I press the first ".as-result-item" within ".as-results" in the modal window)
  step %(I fill in "conversation_subject" with "#{subject}" in the modal window)
  step %(I fill in "conversation_text" with "#{text}" in the modal window)
  step %(I press "Send" in the modal window)
  step %(I wait for the ajax to finish)
end

When /^I reply with "([^"]*)"$/ do |text|
  step %(I am on the conversations page)
  step %(I press the first ".conversation" within ".conversations")
  step %(I wait for the ajax to finish)
  step %(I fill in "message_text" with "#{text}")
  step %(I press "Reply")
  step %(I wait for the ajax to finish)
end

Then /^I send a mobile message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  step %(I follow "New Message")
  step %(I wait for the ajax to finish)
  step %(I fill in "contact_autocomplete" with "#{person}")
  step %(I press the first ".as-result-item" within ".as-results")
  step %(I fill in "conversation_subject" with "#{subject}")
  step %(I fill in "conversation_text" with "#{text}")
  step %(I press "Send")
  step %(I wait for the ajax to finish)
end
