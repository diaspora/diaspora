When /^I enter "([^"]*)" in the search input$/ do |search_term|
  fill_in "q", :with => search_term
end

When /^I click on the first search result$/ do
  within(".tt-menu") do
    find(".tt-suggestion", match: :first).click
  end
end

When /^I press enter in the search input$/ do
  find("input#q").native.send_keys :return
end

Then /^I should not see any search results$/ do
  expect(page).to_not have_selector(".tt-suggestion")
end
