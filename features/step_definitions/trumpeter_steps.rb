def fill_in_autocomplete(selector, value)
  page.execute_script %Q{$('#{selector}').val('#{value}').keyup()}
end

def aspects_dropdown
  find(".dropdown-toggle")
end

def select_from_dropdown(option_text, dropdown)
  dropdown.click
  within ".dropdown-menu" do
    link = find("a:contains('#{option_text}')")
    link.should be_visible
    link.click
  end
  #assert dropdown text is link
end

When /^I trumpet$/ do
  visit new_post_path
end

When /^I write "([^"]*)"$/ do |text|
  fill_in :text, :with => text
end

Then /I mention "([^"]*)"$/ do |text|
  fill_in_autocomplete('textarea.text', '@a')
  sleep(5)
  find("li.active").click
end

When /^I select "([^"]*)" in my aspects dropdown$/ do |title|
  within ".aspect_selector" do
    select_from_dropdown(title, aspects_dropdown)
  end
end

Then /^"([^"]*)" should be a (limited|public) post in my stream$/ do |post_text, scope|
  find_post_by_text(post_text).find(".post_scope").text.should =~ /#{scope}/i
end

When /^I upload a fixture picture with filename "([^"]*)"$/ do |file_name|
  within ".new_photo" do
    attach_file "photo[user_file]", Rails.root.join("spec", "fixtures", file_name)
    click_button :submit
  end

  @image_source = find(".photos img")["src"]
end

Then /^"([^"]*)" should have my photo$/ do |status_text|
  find_post_by_text(status_text).find(".photo_attachments img")["src"].should == @image_source
end