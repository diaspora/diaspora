module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /^its ([\w ]+) page$/
      send("#{$1.gsub(/\W+/, '_')}_path", @it)
    when /^the ([\w ]+) page$/
      send("#{$1.gsub(/\W+/, '_')}_path")
    when /^"(\/.*)"/
      $1
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end

World(NavigationHelpers)
