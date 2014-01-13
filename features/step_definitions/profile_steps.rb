And /^I mark myself as not safe for work$/ do
  check('profile[nsfw]')
end

And /^I mark myself as safe for work$/ do
  uncheck('profile[nsfw]')
end

And /^the "profile[nsfw]" checkbox should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
	field_checked.should be_true
  end
end

And /^the "profile[nsfw]" checkbox should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
	field_checked.should be_false
  end
end
