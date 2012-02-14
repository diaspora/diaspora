And /^I mark myself as not safe for work$/ do
  check('profile[nsfw]')
end

And /^I mark myself as safe for work$/ do
  uncheck('profile[nsfw]')
end
