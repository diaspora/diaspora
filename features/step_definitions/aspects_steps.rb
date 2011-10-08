When /^I click on "([^"]*)" aspect edit icon$/ do |aspect_name|
  When %{I hover over the "ul.sub_nav > li:contains('#{aspect_name}')"}
  within("#aspect_nav") do
    find(:xpath, "//a[@rel='facebox'][.//img[@title='Edit #{aspect_name}']]").click
  end
end

When /^I select only "([^"]*)" aspect$/ do |aspect_name|
  within('#aspect_nav') do
    click_link 'Deselect all'
    click_link aspect_name
  end
  And %{I wait for the ajax to finish}
end
