When /^(.*) in the header$/ do |action|
  within('header') do
    When action
  end
end

And /^I expand the publisher$/ do
  page.execute_script('
    $("#publisher").removeClass("closed");
    $("#publisher").find("textarea").focus();
    ')
end

When /^I append "([^"]*)" to the publisher$/ do |stuff|
  # Wait for the publisher to appear and all the elements to lay out
  wait_until { evaluate_script("$('#status_message_fake_text').focus().length == 1") }

  # Write to the placeholder field and trigger a keyup to start the copy
  page.execute_script <<-JS
    $('#status_message_fake_text').val($('#status_message_fake_text').val() + '#{stuff}');
    $('#status_message_fake_text').keyup();
  JS

  # Wait until the text appears in the placeholder
  wait_until do
    evaluate_script("$('#status_message_fake_text').val().match(/#{stuff}/) != null")
  end

  # WAIT FOR IT!...

  # Wait until the text copy is finished
  wait_until do
    evaluate_script <<-JS
      $('#status_message_text').val() && ($('#status_message_text').val().match(/#{stuff}/) != null)
    JS
  end
end

And /^I hover over the (\w*)$/ do |element|
  if element == 'post'
    name = 'stream_element'
  elsif element == 'comment'
    name = 'comment.posted'
  end
  page.execute_script("$(\".#{name}\").first().mouseover()")
end

When /^I click to delete the first post$/ do
  page.execute_script('$(".stream_element").first().find(".stream_element_delete").click()')
end

When /^I click to delete the first comment$/ do
  page.execute_script('$(".comment.posted").first().find(".comment_delete").click()')
end

And /^I click "([^"]*)" button$/ do |arg1|
  page.execute_script('$(".button:contains('+arg1+')").click()')
end

And /^I preemptively confirm the alert$/ do
  page.evaluate_script("window.confirm = function() { return true; }")
end

And /^I preemptively reject the alert$/ do
  page.evaluate_script("window.confirm = function() { return false; }")
end

When /^(.*) in the modal window$/ do |action|
  within('#facebox') do
    When action
  end
end

When /^(.*) in the aspect list$/ do |action|
  within('#aspect_list') do
    When action
  end
end

When /^I press the first "([^"]*)"(?: within "([^"]*)")?$/ do |link_selector, within_selector|
  with_scope(within_selector) do
    find(:css, link_selector).click
  end
end

When /^I press the ([\d])(nd|rd|st|th) "([^\"]*)"(?: within "([^\"]*)")?$/ do |number, rd, link_selector, within_selector|
  with_scope(within_selector) do
    find(:css, link_selector+":nth-child(#{number})").click
  end
end
Then /^(?:|I )should see a "([^\"]*)"(?: within "([^\"]*)")?$/ do |selector, scope_selector|
  with_scope(scope_selector) do
    page.has_css?(selector).should be_true
  end
end
Then /^I should see "([^\"]*)" in the main content area$/ do |stuff|
  within("#main_stream") do
    Then "I should see #{stuff}"
  end
end

When /^I wait for the ajax to finish$/ do
  wait_until(10) { evaluate_script("$.active") == 0 }
end

When /^I have turned off jQuery effects$/ do
  evaluate_script("$.fx.off = true")
end

When /^I attach the file "([^\"]*)" to hidden element "([^\"]*)"(?: within "([^\"]*)")?$/ do |path, field, selector|
  page.execute_script <<-JS
    $("#{selector || 'body'}").find("input[name=#{field}]").css({opacity: 1});
  JS

  if selector
    When "I attach the file \"#{Rails.root.join(path).to_s}\" to \"#{field}\" within \"#{selector}\""
  else
    When "I attach the file \"#{Rails.root.join(path).to_s}\" to \"#{field}\""
  end

  page.execute_script <<-JS
    $("#{selector || 'body'}").find("input[name=#{field}]").css({opacity: 0});
  JS
end

When /^I click ok in the confirm dialog to appear next$/ do
  evaluate_script <<-JS
    window.confirm = function() { return true; };
  JS
end

When /^I wait for "([^\"]*)" to load$/ do |page_name|
  wait_until(10) do
    uri = URI.parse(current_url)
    current_location = uri.path
    current_location << "?#{uri.query}" unless uri.query.blank?
    current_location == path_to(page_name)
  end
end

Then /^I should get download alert$/ do
  page.evaluate_script("window.alert = function() { return true; }")
end

When /^I search for "([^\"]*)"$/ do |search_term|
  When "I fill in \"q\" with \"#{search_term}\""
  page.execute_script <<-JS
    var e = jQuery.Event("keypress");
    e.keyCode = 13;
    $("#q").trigger(e);
  JS
end

Then /^I should( not)? see the contact dialog$/ do |not_see|
  if not_see
    wait_until { !page.find("#facebox").visible? }
  else
    wait_until { page.find("#facebox .share_with") && page.find("#facebox .share_with").visible? }
  end
end

When /^I add the person to my first aspect$/ do
  steps %Q{
    And I press the first ".add.button" within "#facebox #aspects_list ul > li:first-child"
    And I wait for the ajax to finish
    Then I should see a ".added.button" within "#facebox #aspects_list ul > li:first-child"
  }
end

Then /^I should( not)? see an add contact button$/ do |not_see|
  expected_length = not_see ? 0 : 1
  evaluate_script("$('.add_contact a').length == #{expected_length};")
end

When /^I click on the add contact button$/ do
  page.execute_script("$('.add_contact a').click();")
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
