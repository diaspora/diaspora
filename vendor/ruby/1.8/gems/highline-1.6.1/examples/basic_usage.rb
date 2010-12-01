#!/usr/local/bin/ruby -w

# basic_usage.rb
#
#  Created by James Edward Gray II on 2005-04-28.
#  Copyright 2005 Gray Productions. All rights reserved.

require "rubygems"
require "highline/import"
require "yaml"

contacts = [ ]

class NameClass
  def self.parse( string )
    if string =~ /^\s*(\w+),\s*(\w+)\s*$/
      self.new($2, $1)
    else
      raise ArgumentError, "Invalid name format."
    end
  end

  def initialize(first, last)
    @first, @last = first, last
  end
  
  attr_reader :first, :last
end

begin
  entry = Hash.new
  
  # basic output
  say("Enter a contact:")

  # basic input
  entry[:name]        = ask("Name?  (last, first)  ", NameClass) do |q|
    q.validate = /\A\w+, ?\w+\Z/
  end
  entry[:company]     = ask("Company?  ") { |q| q.default = "none" }
  entry[:address]     = ask("Address?  ")
  entry[:city]        = ask("City?  ")
  entry[:state]       = ask("State?  ") do |q|
    q.case     = :up
    q.validate = /\A[A-Z]{2}\Z/
  end
  entry[:zip]         = ask("Zip?  ") do |q|
    q.validate = /\A\d{5}(?:-?\d{4})?\Z/
  end
  entry[:phone]       = ask( "Phone?  ",
                             lambda { |p| p.delete("^0-9").
                                            sub(/\A(\d{3})/, '(\1) ').
                                            sub(/(\d{4})\Z/, '-\1') } ) do |q|
    q.validate              = lambda { |p| p.delete("^0-9").length == 10 }
    q.responses[:not_valid] = "Enter a phone numer with area code."
  end
  entry[:age]         = ask("Age?  ", Integer) { |q| q.in = 0..105 }
  entry[:birthday]    = ask("Birthday?  ", Date)
  entry[:interests]   = ask( "Interests?  (comma separated list)  ",
                             lambda { |str| str.split(/,\s*/) } )
  entry[:description] = ask("Enter a description for this contact.") do |q|
    q.whitespace = :strip_and_collapse
  end

  contacts << entry
# shortcut for yes and no questions
end while agree("Enter another contact?  ", true)

if agree("Save these contacts?  ", true)
  file_name = ask("Enter a file name:  ") do |q|
    q.validate = /\A\w+\Z/
    q.confirm  = true
  end
  File.open("#{file_name}.yaml", "w") { |file| YAML.dump(contacts, file) }
end
