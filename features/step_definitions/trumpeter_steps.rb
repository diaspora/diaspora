def type_to_mention(typed, user_name)
  #add each of the charcters to jquery.mentionsInput's buffer
  typed.each_char do |char|
    key_code = char.ord
    page.execute_script <<-JAVASCRIPT
      var e = new $.Event("keypress")
      e.which = #{key_code}
      $("textarea.text").trigger(e)
    JAVASCRIPT
  end

  #trigger event that brings up mentions input
  page.execute_script('$("textarea.text").trigger("input")')

  page.find(".mentions-autocomplete-list li:contains('#{user_name}')").click()
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

def assert_post_renders_with(mood)
  find(".post.#{mood.downcase}").should be_present
end

def get_image_filename(filename)
  @image_sources[filename].tap {|src| src.should be_present}
end

def set_image_filename(file_name)
  @image_sources ||= {}
  @image_sources[file_name] = all(".photos img").last["src"].tap {|src| src.should be_present}
end

def find_image_by_filename(filename)
  find("img[src='#{get_image_filename(filename)}']")
end

def upload_photo(file_name)
  orig_photo_count = all(".photos img").size

  within ".new_photo" do
    attach_file "photo[user_file]", Rails.root.join("spec", "fixtures", file_name)
    wait_until { all(".photos img").size == orig_photo_count + 1 }
  end

  set_image_filename(file_name)
end

When /^I trumpet$/ do
  visit new_post_path
end

When /^I write "([^"]*)"(?:| with body "([^"]*)")$/ do |headline, body|
  fill_in 'text', :with => [headline, body].join("\n")
end

Then /I type "([^"]*)" to mention "([^"]*)"$/ do |typed, user_name|
  type_to_mention(typed, user_name)
end

When /^I select "([^"]*)" in my aspects dropdown$/ do |title|
  within ".aspect-selector" do
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

When /^I select the mood "([^"]*)"$/ do |mood|
  click_link mood
end

Then /^the post's (?:default |)mood should (?:still |)be "([^"]*)"$/ do |mood|
  assert_post_renders_with(mood)
end

When /^"([^"]*)" should be in the post's picture viewer$/ do |file_name|
  within(".photo_viewer") do
    find_image_by_filename(file_name).should be_present
  end
end

Then /^it should be a wallpaper frame with the background "([^"]*)"$/ do |file_name|
  assert_post_renders_with("Wallpaper")
  find("div.photo-fill")["data-img-src"].should == get_image_filename(file_name)
end

When /^the frame's headline should be "([^"]*)"$/ do |header_text|
  find("header").text.should == header_text
end

When /^the frame's body should be "([^"]*)"$/ do |body_text|
  find("section.body").text.should == body_text
end

Then /^the post should mention "([^"]*)"$/ do |user_name|
  within('#post-content') { find("a:contains('#{user_name}')").should be_present }
end

When /^I click the "([^"]*)" post$/ do |post_text|
   find(".content:contains('#{post_text}')").click
end

Then /^"([^"]*)" should be the first canvas frame$/ do |post_text|
  find(".canvas-frame:first").should have_content(post_text)
end