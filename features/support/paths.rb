module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^the home page$/
      root_path
    when /^its ([\w ]+) page$/
      send("#{$1.gsub(/\W+/, '_')}_path", @it)
    when /^the ([\w ]+) page$/
      send("#{$1.gsub(/\W+/, '_')}_path")
    when /^my edit profile page$/
      edit_person_path(@me.person)
    when /^my acceptance form page$/
      accept_user_invitation_path(:invitation_token => @me.invitation_token)
    when /^the requestor's profile page$/
      person_path(Request.where(:recipient_id => @me.person.id).first.sender)
    when /^"([^\"]*)"'s page$/
      person_path(User.find_by_email($1).person)
   when /^my account settings page$/
      edit_user_path(@me)  
    when /^"(\/.*)"/
      $1
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
