#!/usr/local/bin/ruby -w

require "rubygems"
require "highline/import"

# The old way, using ask() and say()...
choices = %w{ruby python perl}
say("This is the old way using ask() and say()...")
say("Please choose your favorite programming language:")
say(choices.map { |c| "  #{c}\n" }.join)

case ask("?  ", choices)
when "ruby"
  say("Good choice!")
else
  say("Not from around here, are you?")
end

# The new and improved choose()...
say("\nThis is the new mode (default)...")
choose do |menu|
  menu.prompt = "Please choose your favorite programming language?  "

  menu.choice :ruby do say("Good choice!") end
  menu.choices(:python, :perl) do say("Not from around here, are you?") end
end

say("\nThis is letter indexing...")
choose do |menu|
  menu.index        = :letter
  menu.index_suffix = ") "

  menu.prompt = "Please choose your favorite programming language?  "

  menu.choice :ruby do say("Good choice!") end
  menu.choices(:python, :perl) do say("Not from around here, are you?") end
end

say("\nThis is with a different layout...")
choose do |menu|
  menu.layout = :one_line

  menu.header = "Languages"
  menu.prompt = "Favorite?  "

  menu.choice :ruby do say("Good choice!") end
  menu.choices(:python, :perl) do say("Not from around here, are you?") end
end

say("\nYou can even build shells...")
loop do
  choose do |menu|
    menu.layout = :menu_only
  
    menu.shell  = true
  
    menu.choice(:load, "Load a file.") do |command, details|
      say("Loading file with options:  #{details}...")
    end
    menu.choice(:save, "Save a file.") do |command, details|
      say("Saving file with options:  #{details}...")
    end
    menu.choice(:quit, "Exit program.") { exit }
  end
end
