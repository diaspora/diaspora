When /^I visit url ([^ ]+)$/ do |url|
  visit( url)
end

Then /^I should find '([^']*)' in ([^ ]+)$/ do |pattern,file|
  found = %x!fgrep -o #{pattern} #{file}!
  assert_equal pattern, found.chomp, "Can't find pattern in #{file}"
end

Then /^I should match '([^']*)' in ([^ ]+)$/ do |pattern,file|
  found = `egrep -o '#{pattern}' #{file}`
  assert_match /#{pattern}/, found.chomp, "Can't find #{pattern} in #{file}"
end

When /^I retrieve ([^ ]+) into ([^ ]+)$/ do |url,file|
  system( "wget -q -O #{file} #{url}")
end

Then /^a page\-asset should be ([^ ]+)$/ do |asset_path|
  page.has_content?(asset_path)
end





