When /^I click on "([^"]*)" aspect edit icon$/ do |aspect_name|
  step %{I hover over the "ul.sub_nav > li:contains('#{aspect_name}')"}
  within("#aspect_nav") do
    find('a > .edit').click
  end
end

When /^I select only "([^"]*)" aspect$/ do |aspect_name|
  within('#aspect_nav') do
    click_link 'Aspects'
    click_link 'Select all' if has_link? 'Select all'
    click_link 'Deselect all'
  end
  step %Q(I select "#{aspect_name}" aspect as well)
end

When /^I select "([^"]*)" aspect as well$/ do |aspect_name|
  within('#aspect_nav') do
    click_link aspect_name
  end
  step %Q(I should see "#{aspect_name}" aspect selected)
end

Then /^I should see "([^"]*)" aspect selected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspect_nav") do
    page.has_css?("li.active[data-aspect_id='#{aspect.id}']").should be_true
    page.has_no_css?("li.active[data-aspect_id='#{aspect.id}'] .invisible").should be_true
  end
end

Then /^I should see "([^"]*)" aspect unselected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspect_nav") do
    page.has_css?("li[data-aspect_id='#{aspect.id}']:not(.active) .invisible", visible: false).should be_true
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
