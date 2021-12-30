# frozen_string_literal: true

Then /^I should see a modal$/ do
  step %{I should see a ".modal.in"}
end

Then /^I should see the mention modal$/ do
  step %{I should see a "#mentionModal.in"}
end

When /^I put in my password in the close account modal$/ do
  fill_in("#close_account_password", with: @me.password)
  expect(find("#closeAccountModal input#close_account_password").value).to eq(@me.password)
end

When /^I press "(.*)" in the modal$/ do |txt|
  within(".modal.in") do
    find_button(txt).trigger "click"
  end
end
