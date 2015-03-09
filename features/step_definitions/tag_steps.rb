When(/^I unfollow the "(.*?)" tag$/) do |tag|
  within("#tags_list") do
    li = find('li', text: tag)
    li.hover
    li.find('.delete_tag_following').click
  end
  step 'I confirm the alert'
end
