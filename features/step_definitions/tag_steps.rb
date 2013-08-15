When(/^I unfollow the "(.*?)" tag$/) do |tag|
  page.execute_script("$('#unfollow_#{tag}').css('display', 'block')")
  find("#unfollow_#{tag}").click
  step 'I confirm the alert'
end
