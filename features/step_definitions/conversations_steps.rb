Then /^"([^"]*)" should be part of active conversation$/ do |name|
  within(".conversation_participants") do
    find("img.avatar[title^='#{name}']").should_not be_nil
  end
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  Given %(I am on the conversations page)
  And %(I follow "New Message")
  And %(I wait for the ajax to finish)
  And %(I fill in "contact_autocomplete" with "#{person}" in the modal window)
  And %(I press the first ".as-result-item" within ".as-results" in the modal window)
  And %(I fill in "conversation_subject" with "#{subject}" in the modal window)
  And %(I fill in "conversation_text" with "#{text}" in the modal window)
  And %(I press "Send" in the modal window)
  And %(I wait for the ajax to finish)
end

When /^I reply with "([^"]*)"$/ do |text|
  When %(I am on the conversations page)
  And %(I press the first ".conversation" within ".conversations")
  And %(I wait for the ajax to finish)
  And %(I fill in "message_text" with "#{text}")
  And %(I press "Reply")
  And %(I wait for the ajax to finish)
end
