When /^I enter "([^"]*)" in the search input$/ do |search_term|
  fill_in "q", :with => search_term
end

When /^I click on the first search result$/ do
  within(".ac_results") do
    find("li", match: :first).click
  end
end
