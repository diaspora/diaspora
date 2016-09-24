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

And /^I expand the publisher$/ do
 click_publisher
end

And /^I close the publisher$/ do
  find("#publisher .md-cancel").click
end

Then /^the publisher should be expanded$/ do
  find("#publisher")["class"].should_not include("closed")
end

Then /^the text area wrapper mobile should be with attachments$/ do
  find("#publisher_textarea_wrapper")["class"].should include("with_attachments")
end

And /^I want to mention (?:him|her) from the profile$/ do
  find('#mention_button').click
  within('#mentionModal') do
    click_publisher
  end
end

And /^I hover over the "([^"]+)"$/ do |element|
  find("#{element}", match: :first).hover
end

When /^I prepare the deletion of the first post$/ do
  find(".stream .stream-element", match: :first).hover
  within(find(".stream .stream-element", match: :first)) do
    ctrl = find(".control-icons")
    ctrl.hover
    ctrl.find(".remove_post").click
  end
end

When /^I prepare hiding the first post$/ do
  find(".stream .stream-element", match: :first).hover
  within(find(".stream .stream-element", match: :first)) do
    ctrl = find(".control-icons")
    ctrl.hover
    ctrl.find(".hide_post").click
  end
end

When /^I click to delete the first post$/ do
  accept_alert do
    step "I prepare the deletion of the first post"
  end
end

When /^I click to hide the first post$/ do
  accept_alert do
    step "I prepare hiding the first post"
  end
end

When /^I click to delete the first comment$/ do
  within("div.comment", match: :first) do
    find(".comment_delete", visible: false).click
  end
end

When /^I click to delete the first uploaded photo$/ do
  page.execute_script("$('#photodropzone .x').css('display', 'block');")
  find("#photodropzone .x", match: :first).trigger "click"
end

And /^I click on selector "([^"]*)"$/ do |selector|
  find(selector).click
end

And /^I click on the first selector "([^"]*)"$/ do |selector|
  find(selector, match: :first).click
end

And /^I confirm the alert after (.*)$/ do |action|
  accept_alert do
    step action
  end
end

And /^I reject the alert after (.*)$/ do |action|
  dismiss_confirm do
    step action
  end
end

And /^I should not see any alert after (.*)$/ do |action|
  expect {
    accept_alert do
      step action
    end
  }.to raise_error(Capybara::ModalNotFound)
end

When /^(.*) in the mention modal$/ do |action|
  within('#mentionModal') do
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
    current_scope.should have_no_css(selector, :visible => true)
  end
end

Then /^page should (not )?have "([^\"]*)"$/ do |negate, selector|
  page.should ( negate ? (have_no_css(selector)) : (have_css(selector)) )
end

When /^I have turned off jQuery effects$/ do
  page.execute_script("$.fx.off = true")
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should be filled with "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    field_value = field_value.first if field_value.is_a? Array
    field_value.should == value
  end
end

Then /^I should see (\d+) contacts$/ do |n_posts|
  has_css?("#people_stream .stream-element", count: n_posts.to_i).should be true
end

And /^I scroll down$/ do
  page.execute_script("window.scrollBy(0,3000000)")
end
And /^I scroll down on the notifications dropdown$/ do
  page.execute_script("$('.notifications').scrollTop(350)")
end

Then /^I should have scrolled down$/ do
  expect(page.evaluate_script("window.pageYOffset")).to be > 0
end

Then /^I should have scrolled down on the notification dropdown$/ do
  expect(page.evaluate_script("$('.notifications').scrollTop()")).to be > 0
end


Then /^the notification dropdown should be visible$/ do
  expect(find(:css, "#notification-dropdown")).to be_visible
end

Then /^the notification dropdown scrollbar should be visible$/ do
  find(:css, ".ps-active-y").should be_visible
end

Then /^there should be (\d+) notifications loaded$/ do |n|
  result = page.evaluate_script("$('.media.stream-element').length")
  result.should == n.to_i
end

And "I wait for notifications to load" do
  page.should_not have_selector(".loading")
end

When /^I resize my window to 800x600$/ do
  page.driver.resize(800, 600)
end

Then 'I should see an image attached to the post' do
  step %(I should see a "img" within ".stream-element div.photo_attachments")
end

Then 'I press the attached image' do
  step %(I press the 1st "img" within ".stream-element div.photo_attachments")
end

And "I wait for the popovers to appear" do
  expect(page).to have_selector(".popover", count: 3)
end

And /^I click close on all the popovers$/ do
  find(".popover .close", match: :first).click
  expect(page).to have_selector(".popover", count: 2, visible: false)
  find(".popover .close", match: :first).click
  expect(page).to have_selector(".popover", count: 1, visible: false)
  find(".popover .close", match: :first).click
  expect(page).to_not have_selector(".popover", visible: false)
end

Then /^I should see a flash message indicating success$/ do
  flash_message_success?.should be true
end

Then /^I should see a flash message indicating failure$/ do
  flash_message_failure?.should be true
end

Then /^I should not see a flash message indicating failure$/ do
  expect { flash_message_failure?.should }.to raise_error(Capybara::ElementNotFound)
end

Then /^I should see a flash message with a warning$/ do
  flash_message_alert?.should be true
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

Given /^I have configured a Bitcoin address$/ do
  AppConfig.settings.bitcoin_address = "AAAAAA"
end

Then /^I should see the Bitcoin address$/ do
  find("#bitcoin_address")['value'].should == "AAAAAA"
end

Given /^"([^"]*)" is hidden$/ do |selector|
  page.should have_selector(selector, visible: false)
  page.should_not have_selector(selector)
end

Then(/^I should have a validation error on "(.*?)"$/) do |field_list|
  check_fields_validation_error field_list
end

And /^I activate the first hovercard after loading the notifications page$/ do
  page.should have_css '.notifications .hovercardable'
  first('.notifications .hovercardable').hover
end
