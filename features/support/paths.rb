module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^person_photos page$/
      person_photos_path(@me.person)
    when /^the home(?: )?page$/
      stream_path
    when /^the mobile path$/
      force_mobile_path
    when /^the tag page for "([^\"]*)"$/
      tag_path(Regexp.last_match(1))
    when /^its ([\w ]+) page$/
      send("#{Regexp.last_match(1).gsub(/\W+/, '_')}_path", @it)
    when /^the mobile ([\w ]+) page$/
      public_send("#{Regexp.last_match(1).gsub(/\W+/, '_')}_path", format: "mobile")
    when /^the ([\w ]+) page$/
      public_send("#{Regexp.last_match(1).gsub(/\W+/, '_')}_path")
    when /^my edit profile page$/
      edit_profile_path
    when /^my profile page$/
      person_path(@me.person)
    when /^my acceptance form page$/
      invite_code_path(InvitationCode.first)
    when /^the requestors profile$/
      person_path(Request.where(recipient_id: @me.person.id).first.sender)
    when /^"([^\"]*)"'s page$/
      p = User.find_by_email(Regexp.last_match(1)).person
      {path:         person_path(p),
       # '#diaspora_handle' on desktop, '.description' on mobile
       special_elem: {selector: "#diaspora_handle, .description", text: p.diaspora_handle}
      }
    when /^"([^\"]*)"'s photos page$/
      p = User.find_by_email(Regexp.last_match(1)).person
      person_photos_path p
    when /^my account settings page$/
      edit_user_path
    when /^forgot password page$/
      new_user_password_path
    when /^user applications page$/
      api_openid_connect_user_applications_path
    when %r{^"(/.*)"}
      Regexp.last_match(1)
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end

  def login_page
    path_to "the new user session page"
  end

  def post_path_by_content(text)
    p = Post.find_by_text(text)
    post_path(p)
  end

  def navigate_to(page_name)
    path = path_to(page_name)
    if path.is_a?(Hash)
      visit(path[:path])
      await_elem = path[:special_elem]
      find(await_elem.delete(:selector), await_elem)
    else
      visit(path)
    end
  end

  def confirm_on_page(page_name)
    expect(page).to have_path(path_to(page_name))
  end
end

World(NavigationHelpers)
