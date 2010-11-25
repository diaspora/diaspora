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
    when /^the requestor's profile page$/
      person_path(@me.reload.pending_requests.first.from)
    when /^"(\/.*)"/
      $1
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
