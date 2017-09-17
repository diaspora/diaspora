# frozen_string_literal: true

Then /^I should see a modal$/ do
  step %{I should see a ".modal.in"}
end

Then /^I should see the mention modal$/ do
  step %{I should see a "#mentionModal.in"}
end

When /^I put in my password in the close account modal$/ do
  # Capybara helpers fill_in, set and send_keys currently don't work
  # inside of Bootstrap modals on Travis CI
  execute_script("$(\"#closeAccountModal input#close_account_password\").val(\"#{@me.password}\")")
  expect(find("#closeAccountModal input#close_account_password").value).to eq(@me.password)
end

When /^I press "(.*)" in the modal$/ do |txt|
  within(".modal.in") do
    find_button(txt).trigger "click"
  end
end
