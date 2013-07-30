Then /^"([^"]*)" should be part of active conversation$/ do |name|
  within(".conversation_participants") do
    find("img.avatar[title^='#{name}']").should_not be_nil
  end
end

Then /^I send a message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  step %(I follow "New Message")
  step %(I fill in "contact_autocomplete" with "#{person}" in the modal window)
  step %(I press the first ".as-result-item" within ".as-results" in the modal window)
  step %(I fill in "conversation_subject" with "#{subject}" in the modal window)
  step %(I fill in "conversation_text" with "#{text}" in the modal window)
  step %(I press "Send" in the modal window)
end

When /^I reply with "([^"]*)"$/ do |text|
  step %(I am on the conversations page)
  step %(I press the first ".conversation" within ".conversations")
  step %(I fill in "message_text" with "#{text}")
  step %(I press "Reply")
end

Then /^I send a mobile message with subject "([^"]*)" and text "([^"]*)" to "([^"]*)"$/ do |subject, text, person|
  step %(I am on the conversations page)
  step %(I follow "New Message")
  step %(I fill in "contact_autocomplete" with "#{person}")
  step %(I press the first ".as-result-item" within ".as-results")
  step %(I fill in "conversation_subject" with "#{subject}")
  step %(I fill in "conversation_text" with "#{text}")
  step %(I press "Send")
end

Then /^I should see the participants popover$/ do
  page.execute_script("$('.popover').css('position', 'static')")
  page.should have_css ".popover"
end

Then /^I should see "([^"]*)" as part of the participants popover$/ do |name|
  find(".conversation_participants_popover img.avatar[data-original-title^='#{name}']").should_not be_nil
end

Then /^I close the participants popover$/ do
  find('.popover-title .close', visible: false).click
end

