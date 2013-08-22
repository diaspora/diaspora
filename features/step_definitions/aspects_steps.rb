When /^I click on "([^"]*)" aspect edit icon$/ do |aspect_name|
  within(".all_aspects") do
    li = find('li', text: aspect_name)
    li.hover
    li.find('.modify_aspect').click
  end
end

When /^I select only "([^"]*)" aspect$/ do |aspect_name|
  click_link 'My Aspects'
  within('#aspects_list') do
    click_link 'Select all' if has_link? 'Select all'
    click_link 'Deselect all'
    current_scope.should have_no_css '.selected'
  end
  step %Q(I select "#{aspect_name}" aspect as well)
end

When /^I select "([^"]*)" aspect as well$/ do |aspect_name|
  within('#aspects_list') do
    click_link aspect_name
  end
  step %Q(I should see "#{aspect_name}" aspect selected)
end

Then /^I should see "([^"]*)" aspect selected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspects_list") do
    page.should have_css "li[data-aspect_id='#{aspect.id}'] .selected"
  end
end

Then /^I should see "([^"]*)" aspect unselected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspects_list") do
    page.should have_no_css "li[data-aspect_id='#{aspect.id}'] .selected"
  end
end

When /^I check the first contact list button$/ do
  find(".contact_list .button", match: :first).tap do |button|
    button.click
    button.parent.should have_css ".added"
  end
end

When /^I uncheck the first contact list button$/ do
  find(".contact_list .button", match: :first).tap do |button|
    button.click
    button.parent.should have_css ".add"
    sleep 1 # The expectation above should wait for the request to finsh, but that doesn't work for some reason
  end
end
