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
  end

  step %{I wait for the ajax to finish}

  within('#aspect_nav') do
    click_link 'Deselect all' if has_link? 'Deselect all'
  end

  step %{I wait for the ajax to finish}

  within('#aspect_nav') do
    click_link aspect_name
  end

  step %{I wait for the ajax to finish}
end

When /^I select "([^"]*)" aspect as well$/ do |aspect_name|
  within('#aspect_nav') do
    click_link aspect_name
  end

  step %{I wait for the ajax to finish}
end

When /^I should see "([^"]*)" aspect selected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspect_nav") do
    page.has_css?("li.active[data-aspect_id='#{aspect.id}']").should be_true
    page.has_no_css?("li.active[data-aspect_id='#{aspect.id}'] .invisible").should be_true
  end
end

When /^I should see "([^"]*)" aspect unselected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspect_nav") do
    page.has_css?("li[data-aspect_id='#{aspect.id}']:not(.active) .invisible").should be_true
  end
end
