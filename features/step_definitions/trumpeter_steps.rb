def fill_in_autocomplete(selector, value)
  pending #make me work if yr board, investigate send_keys
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

def go_to_framer
  click_button "Next"
end

def finalize_frame
  click_button "done"
end

def assert_post_renders_with(template_name)
  find(".post")["data-template"].should == template_name.downcase
end

def find_image_by_filename(filename)
  find("img[src='#{@image_sources[filename]}']")
end

def store_image_filename(file_name)
  @image_sources ||= {}
  @image_sources[file_name] = all(".photos img").last["src"]
  @image_sources[file_name].should be_present
end

def upload_photo(file_name)
  orig_photo_count = all(".photos img").size

  within ".new_photo" do
    attach_file "photo[user_file]", Rails.root.join("spec", "fixtures", file_name)
    wait_until { all(".photos img").size == orig_photo_count + 1 }
  end

  store_image_filename(file_name)
end

When /^I trumpet$/ do
  visit new_post_path
end

When /^I write "([^"]*)"$/ do |text|
  fill_in 'text', :with => text
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
  upload_photo(file_name)
end

Then /^"([^"]*)" should have the "([^"]*)" picture$/ do |post_text, file_name|
  within find_post_by_text(post_text) do
    find_image_by_filename(file_name).should be_present
  end
end

When /^I go through the default composer$/ do
  go_to_framer
  finalize_frame
end

When /^I start the framing process$/ do
  go_to_framer
end

When /^I finalize my frame$/ do
  finalize_frame
end

Then /^"([^"]*)" should have (\d+) pictures$/ do |post_text, number_of_pictures|
  find_post_by_text(post_text).all(".photo_attachments img").size.should == number_of_pictures.to_i
end

Then /^I should see "([^"]*)" in the framer preview$/ do |post_text|
  within(find(".post")) { page.should have_content(post_text) }
end

When /^I select the mood "([^"]*)"$/ do |template_name|
  select template_name, :from => 'template'
end

Then /^the post's mood should (?:still |)be "([^"]*)"$/ do |template_name|
  assert_post_renders_with(template_name)
end

When /^"([^"]*)" should be in the post's picture viewer$/ do |file_name|
  within(".photo_viewer") do
    find_image_by_filename(file_name).should be_present
  end
end