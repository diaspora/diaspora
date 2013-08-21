module ScreenshotCukeHelpers

  def set_screenshot_location(path)
    @screenshot_path = Rails.root.join('tmp','screenshots', path)
    @screenshot_path.mkpath unless @screenshot_path.exist?
  end

  def take_screenshot(name, path)
    visit send("#{path}_path")
    browser = page.driver.browser
    pic = @screenshot_path.join("#{name}.png")

    sleep 0.5

    browser.manage.window.resize_to(1280, 1024)
    browser.save_screenshot(pic)
  end

  def take_screenshots_without_login
    pages = {
      'register' => 'new_user_registration',
      'login'    => 'user_session'
    }

    pages.each do |name, path|
      take_screenshot name, path
    end
  end

  def take_screenshots_with_login
    pages = {
      'stream'        => 'stream',
      'activity'      => 'activity_stream',
      'mentions'      => 'mentioned_stream',
      'aspects'       => 'aspects_stream',
      'tags'          => 'followed_tags_stream',
      'contacts'      => 'contacts',
      'settings'      => 'edit_user',
      'notifications' => 'notifications',
      'conversations' => 'conversations',
      'logout'        => 'destroy_user_session'
    }

    pages.each do |name, path|
      take_screenshot name, path
    end
  end

end
World(ScreenshotCukeHelpers)


When /^(.*) in the header$/ do |action|
  within('header') do
    step action
  end
end

And /^I submit the form$/ do
  find("input[type='submit']").click
end

Then /^the "([^"]*)" field should have a validation error$/ do |field|
  find_field(field).has_xpath?(".//ancestor::div[contains(@class, 'control-group')]/div[contains(@class, 'field_with_errors')]")
end


Then /^following field[s]? should have validation error[s]?:$/ do |fields|
  fields.raw.each do |field|
    step %{the "#{field[0]}" field should have a validation error}
  end
end

And /^I expand the publisher$/ do
 click_publisher
end

When 'I click the aspects title' do
  find('.home_selector').click
end

When /^I press the aspect dropdown$/ do
  find('.dropdown .button').click
end

And /^I toggle the aspect "([^"]*)"$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  find(".dropdown li[data-aspect_id='#{aspect.id}']").click
end

Then /^the publisher should be collapsed$/ do
  find("#publisher")["class"].should include("closed")
end

Then /^the publisher should be expanded$/ do
  find("#publisher")["class"].should_not include("closed")
end

Then /^the text area wrapper mobile should be with attachments$/ do
  find("#publisher_textarea_wrapper")["class"].should include("with_attachments")
end

When /^I append "([^"]*)" to the publisher$/ do |stuff|
  elem = find('#status_message_fake_text')
  elem.native.send_keys(' ' + stuff)

  find('#status_message_text', visible: false).value.should include(stuff)
end

When /^I append "([^"]*)" to the publisher mobile$/ do |stuff|
  elem = find('#status_message_text')
  elem.native.send_keys(' ' + stuff)

  find('#status_message_text').value.should include(stuff)
end

And /^I want to mention (?:him|her) from the profile$/ do
  find('#mention_button').click
  within('#facebox') do
    click_publisher
  end
end

And /^I hover over the "([^"]+)"$/ do |element|
  page.execute_script("$(\"#{element}\").first().addClass('hover')")
end

When /^I prepare the deletion of the first post$/ do
  within('.stream_element', match: :first) do
    find('.remove_post', visible: false).click
  end
end

When /^I click to delete the first post$/ do
  step "I prepare the deletion of the first post"
  step "I confirm the alert"
end

When /^I click to delete the first comment$/ do
  within("div.comment", match: :first) do
    find(".comment_delete", visible: false).click
  end
end

When /^I click to delete the first uploaded photo$/ do
  page.execute_script("$('#photodropzone .x').css('display', 'block');")
  find("#photodropzone .x", match: :first).click
end

And /^I click "([^"]*)" button$/ do |arg1|
  page.execute_script('$(".button:contains('+arg1+')").click()')
end

And /^I click on selector "([^"]*)"$/ do |selector|
  find(selector).click
end

And /^I click on the first selector "([^"]*)"$/ do |selector|
  find(selector, match: :first).click
end

And /^I confirm the alert$/ do
  page.driver.browser.switch_to.alert.accept
end

And /^I reject the alert$/ do
  page.driver.browser.switch_to.alert.dismiss
end

When /^(.*) in the modal window$/ do |action|
  within('#facebox') do
    step action
  end
end

When /^I press the first "([^"]*)"(?: within "([^"]*)")?$/ do |link_selector, within_selector|
  with_scope(within_selector) do
    current_scope.find(link_selector, match: :first).click
  end
end

When /^I press the ([\d])(?:nd|rd|st|th) "([^\"]*)"(?: within "([^\"]*)")?$/ do |number, link_selector, within_selector|
  with_scope(within_selector) do
    current_scope.find(:css, link_selector+":nth-child(#{number})").click
  end
end

Then /^(?:|I )should see a "([^\"]*)"(?: within "([^\"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    current_scope.should have_css selector
  end
end

Then /^(?:|I )should not see a "([^\"]*)"(?: within "([^\"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    current_scope.has_css?(selector, :visible => true).should be_false
  end
end

Then /^page should (not )?have "([^\"]*)"$/ do |negate, selector|
  page.has_css?(selector).should ( negate ? be_false : be_true )
end

When /^I have turned off jQuery effects$/ do
  page.execute_script("$.fx.off = true")
end

When /^I search for "([^\"]*)"$/ do |search_term|
  fill_in "q", :with => search_term
  find_field("q").native.send_key(:enter)
  find("#leftNavBar")
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should be filled with "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    field_value = field_value.first if field_value.is_a? Array
    if field_value.respond_to? :should
      field_value.should == value
    else
      assert_equal(value, field_value)
    end
  end
end

Then /^I should see (\d+) posts$/ do |n_posts|
  has_css?("#main_stream .stream_element", :count => n_posts.to_i).should be_true
end

Then /^I should see (\d+) contacts$/ do |n_posts|
  has_css?("#people_stream .stream_element", :count => n_posts.to_i).should be_true
end

And /^I scroll down$/ do
  page.execute_script("window.scrollBy(0,3000000)")
end

Then /^the notification dropdown should be visible$/ do
  find(:css, "#notification_dropdown").should be_visible
end

When /^I resize my window to 800x600$/ do
  page.execute_script <<-JS
    window.resizeTo(800,600);
  JS
end

Then /^I follow Edit Profile in the same window$/ do
  page.execute_script("$('a[href=\"#{edit_profile_path}\"]').removeAttr('target')")

  step %(I follow "Edit Profile")
end

Then 'I should see an image attached to the post' do
  step %{I should see a "img" within ".stream_element div.photo_attachments"}
end

Then 'I press the attached image' do
  step %{I press the 1st "img" within ".stream_element div.photo_attachments"}
end

And "I wait for the popovers to appear" do
  page.should have_selector(".popover", count: 3)
end

And /^I click close on all the popovers$/ do
  page.execute_script("$('.popover .close').click();")
  page.should_not have_selector(".popover .close")
end

Then /^I should see first post deletion link$/ do
  page.should have_selector '.stream_element .delete', match: :first
end

Then /^I should not see ajax loader on deletion link place$/ do
  page.should_not have_selector '.hide_loader'
end

Then /^I should see a flash message indicating success$/ do
  flash_message_success?.should be_true
end

Then /^I should see a flash message indicating failure$/ do
  flash_message_failure?.should be_true
end

Then /^I should see a flash message containing "(.+)"$/ do |text|
  flash_message_containing? text
end

Given /^the reference screenshot directory is used$/ do
  set_screenshot_location 'reference'
end

Given /^the comparison screenshot directory is used$/ do
  set_screenshot_location 'current'
end

When /^I take the screenshots while logged out$/ do
  take_screenshots_without_login
end

When /^I take the screenshots while logged in$/ do
  take_screenshots_with_login
end

When /^I focus the "([^"]+)" field$/ do |field|
  find_field(field).click
end

Given /^I have configured a Bitcoin wallet$/ do
  AppConfig.settings.bitcoin_wallet_id = "AAAAAA"
end

Then /^I should see the Bitcoin wallet ID$/ do
  find("#bitcoin_address")['value'].should == "AAAAAA"
end
