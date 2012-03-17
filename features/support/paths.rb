module NavigationHelpers
  def path_to(page_name)
    case page_name
      when /^the home(?: )?page$/
        stream_path
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
        invite_code_path(InvitationCode.first)
      when /^the requestors profile$/
        person_path(Request.where(:recipient_id => @me.person.id).first.sender)
      when /^"([^\"]*)"'s page$/
        person_path(User.find_by_email($1).person)
      when /^my account settings page$/
        edit_user_path
      when /^"(\/.*)"/
        $1
      else
        raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
