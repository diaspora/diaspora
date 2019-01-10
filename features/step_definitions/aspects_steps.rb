# frozen_string_literal: true

module AspectCukeHelpers
  def click_aspect_dropdown
    find(".aspect-dropdown .dropdown-toggle").trigger "click"
  end

  def toggle_aspect(a_name)
    a_id = if "Public" == a_name
             "public"
           else
             @me.aspects.where(name: a_name).pluck(:id).first
           end
    aspect_css = ".aspect-dropdown li[data-aspect_id='#{a_id}']"
    expect(page).to have_selector(aspect_css)
    find(aspect_css).click
  end

  def toggle_aspect_via_ui(aspect_name)
    aspects_dropdown = find(".aspect-membership-dropdown .dropdown-toggle", match: :first)
    aspects_dropdown.trigger "click"
    selected_aspect_count = all(".aspect-membership-dropdown.open .dropdown-menu li.selected", wait: false).length
    aspect = find(".aspect-membership-dropdown.open .dropdown-menu li", text: aspect_name)
    aspect_selected = aspect["class"].include? "selected"
    aspect.trigger "click"
    expect(find(".aspect-membership-dropdown .dropdown-menu", visible: false)).to have_no_css(".loading")

    # close dropdown
    page.should have_no_css('#profile.loading')
    unless selected_aspect_count == 0 or (selected_aspect_count == 1 and aspect_selected )
      aspects_dropdown.trigger "click"
    end
  end

  def aspect_dropdown_visible?
    expect(find('.aspect-membership-dropdown.open')).to be_visible
  end
end
World(AspectCukeHelpers)

Given /^I have an aspect called "([^\"]*)"$/ do |aspect_name|
  @me.aspects.create!(name: aspect_name)
  @me.reload
end

Given /^I have an aspect called "([^\"]*)" with auto follow back$/ do |aspect_name|
  aspect = @me.aspects.create!(name: aspect_name)
  @me.auto_follow_back = true
  @me.auto_follow_back_aspect = aspect
  @me.save
  @me.reload
end

Given /^I have following aspect[s]?:$/ do |fields|
  fields.raw.each do |field|
    @me.aspects.create!(name: field[0])
  end
  @me.reload
end

When /^I click on "([^"]*)" aspect edit icon$/ do |aspect_name|
  within(".all-aspects") do
    li = find('li', text: aspect_name)
    li.hover
    li.find('.modify_aspect').click
  end
end

When /^I select only "([^"]*)" aspect$/ do |aspect_name|
  click_link "My aspects"
  expect(find("#aspect-stream-container")).to have_css(".loader.hidden", visible: false)
  within("#aspects_list") do
    all(".selected", wait: false).each do |node|
      aspect_item = node.find(:xpath, "..")
      aspect_item.click
      expect(aspect_item).to have_no_css ".selected"
    end
    expect(current_scope).to have_no_css ".selected"
  end
  step %Q(I select "#{aspect_name}" aspect as well)
end

When /^I select "([^"]*)" aspect as well$/ do |aspect_name|
  within('#aspects_list') do
    click_link aspect_name
  end
  step %Q(I should see "#{aspect_name}" aspect selected)
end

When /^I select all aspects$/ do
  within('#aspects_list') do
    click_link "Select all"
  end
end

When /^I add the first person to the aspect$/ do
  find(".contact_add-to-aspect", match: :first).tap do |button|
    button.click
    button.query_scope.should have_css ".contact_remove-from-aspect"
  end
end

When /^I remove the first person from the aspect$/ do
  find(".contact_remove-from-aspect", match: :first).tap do |button|
    button.click
    button.query_scope.should have_css ".contact_add-to-aspect"
    sleep 1 # The expectation above should wait for the request to finsh, but that doesn't work for some reason
  end
end

When /^I press the aspect dropdown$/ do
  click_aspect_dropdown
end

When /^(.*) in the aspect creation modal$/ do |action|
  within("#newAspectModal") do
    step action
  end
end

When /^I drag "([^"]*)" (up|down)$/ do |aspect_name, direction|
  page.execute_script("$('#aspect_nav .list-group').sortable('option', 'tolerance', 'pointer');")
  aspect_id = @me.aspects.where(name: aspect_name).first.id
  aspect = find(:xpath, "//div[@id='aspect_nav']/ul/a[@data-aspect-id='#{aspect_id}']")
  target = direction == "up" ? aspect.all(:xpath, "./preceding-sibling::a").last :
                               aspect.all(:xpath, "./following-sibling::a").first
  aspect.drag_to target
  expect(page).to have_no_css "#aspect_nav .ui-sortable.syncing"
end

And /^I toggle the aspect "([^"]*)"$/ do |name|
  toggle_aspect(name)
end

Then /^I should see "([^"]*)" within the contact aspect dropdown$/ do |aspect_name|
  expect(find(".dropdown-toggle .text")).to have_content aspect_name
end

Then /^I should see "([^"]*)" aspect selected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspects_list") do
    current_scope.should have_css "li[data-aspect_id='#{aspect.id}'] .selected"
  end
end

Then /^I should see "([^"]*)" aspect unselected$/ do |aspect_name|
  aspect = @me.aspects.where(:name => aspect_name).first
  within("#aspects_list") do
    current_scope.should have_no_css "li[data-aspect_id='#{aspect.id}'] .selected"
  end
end

Then /^the aspect dropdown should be visible$/ do
  aspect_dropdown_visible?
end

Then /^I should see "([^"]*)" as (\d+). aspect$/ do |aspect_name, position|
  expect(find("#aspect_nav a:nth-child(#{position.to_i + 2})")).to have_text aspect_name
end
