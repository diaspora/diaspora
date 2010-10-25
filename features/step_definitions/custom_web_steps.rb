When /^(.*) in the header$/ do |action|
  within('header') do
    When action
  end
end

When /^(.*) in the modal window$/ do |action|
  within('#fancybox-wrap') do
    When action
  end
end

When /^(.*) in the aspect list$/ do |action|
  within('#aspect_list') do
    When action
  end
end

Then /^I should see "([^\"]*)" in the main content area$/ do |stuff|
  within("#stream") do
    Then "I should see #{stuff}"
  end
end