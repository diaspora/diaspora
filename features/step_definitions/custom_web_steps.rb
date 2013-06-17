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
  click_button :submit
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

  wait_until do
    find('#status_message_text').value.include?(stuff)
  end
end

When /^I append "([^"]*)" to the publisher mobile$/ do |stuff|
  elem = find('#status_message_text')
  elem.native.send_keys(' ' + stuff)

  wait_until do
    find('#status_message_text').value.include?(stuff)
  end
end

And /^I want to mention (?:him|her) from the profile$/ do
  click_link("Mention")
  wait_for_ajax_to_finish
  within('#facebox') do
    click_publisher
  end
end

And /^I hover over the "([^"]+)"$/ do |element|
  page.execute_script("$(\"#{element}\").first().addClass('hover')")
end

When /^I click to delete the first post$/ do
  page.execute_script('$(".stream_element").first().find(".remove_post").first().click()')
end

When /^I click to delete the first comment$/ do
  find(".comment").find(".comment_delete").click()
end

When /^I click to delete the first uploaded photo$/ do
  page.execute_script('$("#photodropzone").find(".x").first().click()')
end

And /^I click "([^"]*)" button$/ do |arg1|
  page.execute_script('$(".button:contains('+arg1+')").click()')
end

And /^I click on selector "([^"]*)"$/ do |selector|
  page.execute_script("$('#{selector}').click();")
end

And /^I click on the first selector "([^"]*)"$/ do |selector|
  page.execute_script("$('#{selector}').first().click();")
end

And /^I preemptively confirm the alert$/ do
  page.evaluate_script("window.confirm = function() { return true; }")
end

And /^I preemptively reject the alert$/ do
  page.evaluate_script("window.confirm = function() { return false; }")
end

When /^(.*) in the modal window$/ do |action|
  within('#facebox') do
    step action
  end
end

When /^I press the first "([^"]*)"(?: within "([^"]*)")?$/ do |link_selector, within_selector|
  with_scope(within_selector) do
    find(:css, link_selector).click
  end
end

When /^I press the ([\d])(?:nd|rd|st|th) "([^\"]*)"(?: within "([^\"]*)")?$/ do |number, link_selector, within_selector|
  with_scope(within_selector) do
    find(:css, link_selector+":nth-child(#{number})").click
  end
end

Then /^(?:|I )should see a "([^\"]*)"(?: within "([^\"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    page.has_css?(selector).should be_true
  end
end

Then /^(?:|I )should not see a "([^\"]*)"(?: within "([^\"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    page.has_css?(selector, :visible => true).should be_false
  end
end

Then /^page should (not )?have "([^\"]*)"$/ do |negate, selector|
  page.has_css?(selector).should ( negate ? be_false : be_true )
end

When /^I wait for the ajax to finish$/ do
  wait_for_ajax_to_finish
end

When /^I have turned off jQuery effects$/ do
  evaluate_script("$.fx.off = true")
end

When /^I attach the file "([^\"]*)" to hidden element "([^\"]*)"(?: within "([^\"]*)")?$/ do |path, field, selector|
  page.execute_script <<-JS
    $("#{selector || 'body'}").find("input[name=#{field}]").css({opacity: 1});
  JS

  if selector
    step "I attach the file \"#{Rails.root.join(path).to_s}\" to \"#{field}\" within \"#{selector}\""
  else
    step "I attach the file \"#{Rails.root.join(path).to_s}\" to \"#{field}\""
  end

  page.execute_script <<-JS
    $("#{selector || 'body'}").find("input[name=#{field}]").css({opacity: 0});
  JS
end

Then /^I should get download alert$/ do
  page.evaluate_script("window.alert = function() { return true; }")
end

When /^I search for "([^\"]*)"$/ do |search_term|
  fill_in "q", :with => search_term
  find_field("q").native.send_key(:enter)
  sleep(2)
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
  evaluate_script("window.scrollBy(0,3000000)")
  step "I wait for the ajax to finish"
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
  wait_until(30) { evaluate_script('$(".popover").length') == 3 }
end

And /^I click close on all the popovers$/ do
  page.execute_script("var time = 400; $('.popover .close').each(
          function(index, element){ setTimeout(function(){ $(element).click()},time);
          time += 800;
 });")
end

Then /^I should see first post deletion link$/ do
  page.evaluate_script("$('.stream_element .delete').first().css('display')").should == "inline"
end

Then /^I should not see ajax loader on deletion link place$/ do
  page.evaluate_script("$('.hide_loader').first().css('display')").should == "none"
end

Then /^I should see a flash message indicating success$/ do
  flash_message_success?
end

Then /^I should see a flash message indicating failure$/ do
  flash_message_failure?
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
