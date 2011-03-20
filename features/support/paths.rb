module NavigationHelpers
  def path_to(page_name)
    case page_name
      when /^the home(?: )?page$/
        root_path
      when /^step (\d)$/
        if $1.to_i == 1
          getting_started_path
        else
          getting_started_path(:step => $1)
        end
      when /^the tag page for "([^\"]*)"$/
        tag_path($1)
      when /^its ([\w ]+) page$/
        send("#{$1.gsub(/\W+/, '_')}_path", @it)
      when /^the ([\w ]+) page$/
        send("#{$1.gsub(/\W+/, '_')}_path")
      when /^my edit profile page$/
        edit_profile_path
      when /^my profile page$/
        person_path(@me.person)
      when /^my acceptance form page$/
        accept_user_invitation_path(:invitation_token => @me.invitation_token)
      when /^the requestors profile$/
        person_path(Request.where(:recipient_id => @me.person.id).first.sender)
      when /^"([^\"]*)"'s page$/
        person_path(User.find_by_email($1).person)
      when /^my account settings page$/
        edit_user_path(@me)
      when /^the photo page for "([^\"]*)"'s post "([^\"]*)"$/
        photo_path(User.find_by_email($1).posts.find_by_text($2))
      when /^"(\/.*)"/
        $1
      else
        raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
